# The only command CI may run on the backend: start a release (API image from
# ECR plus the compose/nginx bundle from S3), and roll back if the API stops
# answering through nginx.
resource "aws_ssm_document" "deploy_backend" {
  name            = "zendcraft-deploy-backend"
  document_type   = "Command"
  document_format = "YAML"

  content = <<-YAML
    schemaVersion: "2.2"
    description: Deploy a zendcraft backend release with Docker Compose.
    parameters:
      ArtifactKey:
        type: String
        description: Object key of the release bundle, e.g. backend/<commit sha>.tar.gz
        allowedPattern: "^backend/[0-9a-f]{40}\\.tar\\.gz$"
    mainSteps:
      - action: aws:runShellScript
        name: deploy
        inputs:
          timeoutSeconds: "600"
          runCommand:
            - |
              set -euo pipefail
              export HOME=/root
              APP=/opt/zendcraft
              KEY="{{ ArtifactKey }}"
              SHA=$(basename "$KEY" .tar.gz)
              export API_IMAGE="${aws_ecr_repository.api.repository_url}:$SHA"
              WORK=$(mktemp -d)
              trap 'rm -rf "$WORK"' EXIT

              aws s3 cp "s3://${aws_s3_bucket.deploy_artifacts.bucket}/$KEY" "$WORK/bundle.tar.gz" --region ${data.aws_region.current.region}
              mkdir "$WORK/bundle"
              tar -xzf "$WORK/bundle.tar.gz" -C "$WORK/bundle"

              aws ecr get-login-password --region ${data.aws_region.current.region} \
                | docker login --username AWS --password-stdin "${split("/", aws_ecr_repository.api.repository_url)[0]}"

              # Copy files in place rather than replacing them: nginx bind-mounts
              # its config, and a new inode wouldn't be seen by the container.
              install_files() {
                cp "$1/compose.yaml" "$APP/compose.yaml"
                mkdir -p "$APP/nginx"
                cp -r "$1/nginx/." "$APP/nginx/"
              }

              up() {
                docker compose --project-directory "$APP" up -d --no-build --wait --wait-timeout 90 \
                  && docker compose --project-directory "$APP" exec -T nginx nginx -s reload
              }

              healthy() {
                for _ in $(seq 1 10); do
                  if curl -fs http://127.0.0.1/api/java-server-status | grep -q '"online":'; then return 0; fi
                  sleep 2
                done
                return 1
              }

              PREVIOUS_IMAGE=$(cat "$APP/image" 2>/dev/null || true)
              rm -rf "$APP/previous"
              mkdir -p "$APP/previous"
              if [ -f "$APP/compose.yaml" ]; then
                cp -r "$APP/compose.yaml" "$APP/nginx" "$APP/previous/"
              fi

              install_files "$WORK/bundle"
              if docker compose --project-directory "$APP" pull --quiet && up && healthy; then
                echo "$API_IMAGE" > "$APP/image"
                docker image prune -af > /dev/null
                echo "Deployed $SHA"
                exit 0
              fi

              echo "Deploy failed health check; rolling back" >&2
              if [ -n "$PREVIOUS_IMAGE" ]; then
                install_files "$APP/previous"
                API_IMAGE="$PREVIOUS_IMAGE" up
              fi
              exit 1
  YAML
}

data "aws_region" "current" {}
