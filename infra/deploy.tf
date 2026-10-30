# The only command CI may run on the backend: install a build from the
# artifacts bucket, restart pm2, and roll back if the API stops answering.
resource "aws_ssm_document" "deploy_backend" {
  name            = "zendcraft-deploy-backend"
  document_type   = "Command"
  document_format = "YAML"

  content = <<-YAML
    schemaVersion: "2.2"
    description: Deploy a zendcraft backend build from S3 and restart pm2.
    parameters:
      ArtifactKey:
        type: String
        description: Object key of the build archive, e.g. backend/<commit sha>.tar.gz
        allowedPattern: "^backend/[0-9a-f]{40}\\.tar\\.gz$"
    mainSteps:
      - action: aws:runShellScript
        name: deploy
        inputs:
          timeoutSeconds: "600"
          runCommand:
            - |
              set -euo pipefail
              APP=/home/ec2-user/backend
              WORK=$(mktemp -d)
              trap 'rm -rf "$WORK"' EXIT

              aws s3 cp "s3://${aws_s3_bucket.deploy_artifacts.bucket}/{{ ArtifactKey }}" "$WORK/build.tar.gz" --region ${data.aws_region.current.region}
              mkdir "$WORK/build"
              tar -xzf "$WORK/build.tar.gz" -C "$WORK/build"

              rm -rf "$APP/dist.previous" "$APP/package.previous.json" "$APP/package-lock.previous.json"
              cp -a "$APP/dist" "$APP/dist.previous"
              cp -a "$APP/package.json" "$APP/package.previous.json"
              cp -a "$APP/package-lock.json" "$APP/package-lock.previous.json"

              rm -rf "$APP/dist"
              cp -a "$WORK/build/dist" "$APP/dist"
              cp "$WORK/build/package.json" "$WORK/build/package-lock.json" "$WORK/build/version.txt" "$APP/"
              chown -R ec2-user:ec2-user "$APP"

              run_as_app() { sudo -u ec2-user -i bash -c "cd $APP && $1"; }

              healthy() {
                for _ in $(seq 1 15); do
                  if curl -fsS -o /dev/null http://localhost:3000/api/java-server-status; then return 0; fi
                  sleep 2
                done
                return 1
              }

              if run_as_app "npm ci --omit=dev --no-audit --no-fund" \
                && run_as_app "pm2 restart backend --update-env" \
                && healthy; then
                run_as_app "pm2 save"
                echo "Deployed $(cat "$APP/version.txt")"
                exit 0
              fi

              echo "Deploy failed health check; rolling back" >&2
              rm -rf "$APP/dist"
              mv "$APP/dist.previous" "$APP/dist"
              mv "$APP/package.previous.json" "$APP/package.json"
              mv "$APP/package-lock.previous.json" "$APP/package-lock.json"
              run_as_app "npm ci --omit=dev --no-audit --no-fund"
              run_as_app "pm2 restart backend --update-env"
              exit 1
  YAML
}

data "aws_region" "current" {}
