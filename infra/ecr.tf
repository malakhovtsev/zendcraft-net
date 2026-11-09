resource "aws_ecr_repository" "api" {
  name = "zendcraft-api"

  # Tags are commit SHAs, so they never change in practice; staying mutable
  # lets a failed deploy workflow be re-run.
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the last 10 images for rollbacks"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

# Lets the backend instance pull the images that CI pushes.
data "aws_iam_policy_document" "backend_pull_images" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = [aws_ecr_repository.api.arn]
  }
}

resource "aws_iam_role_policy" "backend_pull_images" {
  name   = "pull-api-images"
  role   = aws_iam_role.backend.id
  policy = data.aws_iam_policy_document.backend_pull_images.json
}
