locals {
  github_repo = "malakhovtsev/zendcraft-net"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# Only workflows running on the repo's main branch can assume this role.
data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${local.github_repo}:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "zendcraft-github-deploy"
  description        = "Assumed by GitHub Actions on main to deploy zendcraft.net"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
}

data "aws_iam_policy_document" "github_deploy" {
  statement {
    sid       = "SyncFrontend"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.site.arn]
  }

  statement {
    sid       = "WriteFrontendFiles"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }

  statement {
    sid       = "InvalidateCache"
    actions   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }

  statement {
    sid       = "UploadBackendBuild"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.deploy_artifacts.arn}/backend/*"]
  }
}

resource "aws_iam_role_policy" "github_deploy" {
  name   = "deploy"
  role   = aws_iam_role.github_deploy.id
  policy = data.aws_iam_policy_document.github_deploy.json
}

resource "aws_s3_bucket" "deploy_artifacts" {
  bucket = "zendcraft-deploy-artifacts-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_public_access_block" "deploy_artifacts" {
  bucket                  = aws_s3_bucket.deploy_artifacts.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "deploy_artifacts" {
  bucket = aws_s3_bucket.deploy_artifacts.id

  rule {
    id     = "expire-old-builds"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

# Lets the backend instance download the builds that CI uploads.
data "aws_iam_policy_document" "backend_read_artifacts" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.deploy_artifacts.arn}/backend/*"]
  }
}

resource "aws_iam_role_policy" "backend_read_artifacts" {
  name   = "read-deploy-artifacts"
  role   = aws_iam_role.backend.id
  policy = data.aws_iam_policy_document.backend_read_artifacts.json
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}
