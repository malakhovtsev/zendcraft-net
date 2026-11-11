# The API runs on Lambda from the same image as before; CloudFront reaches it
# through a function URL that only accepts requests CloudFront has signed.

variable "java_server_host" {
  description = "Address of the Java 1.5.2 game server the API pings"
  type        = string
  sensitive   = true
}

variable "java_server_port" {
  description = "Port of the Java 1.5.2 game server"
  type        = number
  default     = 25565
}

locals {
  api_function_name = "zendcraft-api"
}

# The function is created from the newest image in ECR; after that, the deploy
# workflow owns which image it runs.
data "aws_ecr_image" "api_latest" {
  repository_name = aws_ecr_repository.api.name
  most_recent     = true
}

data "aws_iam_policy_document" "api_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "api" {
  name               = "zendcraft-api-lambda"
  assume_role_policy = data.aws_iam_policy_document.api_assume.json
}

resource "aws_iam_role_policy_attachment" "api_logs" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${local.api_function_name}"
  retention_in_days = 14
}

# Lambda pulls the image with its own service identity, so the repository has
# to allow it, limited to this function.
data "aws_iam_policy_document" "api_image_pull" {
  statement {
    actions = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "aws:sourceArn"
      values   = ["arn:aws:lambda:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:function:${local.api_function_name}"]
    }
  }
}

resource "aws_ecr_repository_policy" "api" {
  repository = aws_ecr_repository.api.name
  policy     = data.aws_iam_policy_document.api_image_pull.json
}

resource "aws_lambda_function" "api" {
  function_name = local.api_function_name
  role          = aws_iam_role.api.arn
  package_type  = "Image"
  image_uri     = data.aws_ecr_image.api_latest.image_uri
  architectures = ["x86_64"]
  memory_size   = 512

  # The status route waits up to 5 s for the game server.
  timeout = 10

  environment {
    variables = {
      JAVA_SERVER_HOST = var.java_server_host
      JAVA_SERVER_PORT = tostring(var.java_server_port)
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  depends_on = [
    aws_cloudwatch_log_group.api,
    aws_ecr_repository_policy.api,
    aws_iam_role_policy_attachment.api_logs,
  ]
}

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "AWS_IAM"
}

resource "aws_cloudfront_origin_access_control" "api" {
  name                              = "zendcraft-api"
  description                       = "Signs CloudFront's requests to the API function URL"
  origin_access_control_origin_type = "lambda"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# A function URL call needs both permissions; both are limited to this
# distribution.
resource "aws_lambda_permission" "api_url_from_cloudfront" {
  statement_id           = "AllowCloudFrontInvokeFunctionUrl"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.api.function_name
  principal              = "cloudfront.amazonaws.com"
  source_arn             = aws_cloudfront_distribution.site.arn
  function_url_auth_type = "AWS_IAM"
}

resource "aws_lambda_permission" "api_invoke_from_cloudfront" {
  statement_id             = "AllowCloudFrontInvokeFunction"
  action                   = "lambda:InvokeFunction"
  function_name            = aws_lambda_function.api.function_name
  principal                = "cloudfront.amazonaws.com"
  source_arn               = aws_cloudfront_distribution.site.arn
  invoked_via_function_url = true
}
