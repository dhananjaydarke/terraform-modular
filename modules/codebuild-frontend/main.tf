terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  policy = {
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.bucket_name}",
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = ["cloudfront:CreateInvalidation"]
        Resource = "*"
      }
    ]
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-cb-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge(var.tags, { Name = "${var.name}-cb-role" })
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.name}-cb-policy"
  role   = aws_iam_role.this.id
  policy = jsonencode(local.policy)
}

resource "aws_codebuild_project" "this" {
  name         = var.name
  service_role = aws_iam_role.this.arn
  description  = "Build frontend and sync to S3/CloudFront"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
    environment_variable {
      name  = "BUCKET_NAME"
      value = var.bucket_name
    }
    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = var.cloudfront_distribution_id
    }
    environment_variable {
      name  = "API_BASE_URL"
      value = var.api_base_url
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }
  }

  source {
    type            = "GITHUB"
    location        = var.github_repo
    buildspec       = var.buildspec != "" ? var.buildspec : null
    git_clone_depth = 1
  }

  dynamic "source_version" {
    for_each = var.github_branch != "" ? [var.github_branch] : []
    content  = source_version.value
  }

  tags = merge(var.tags, { Name = var.name })
}

output "project_name" {
  value       = aws_codebuild_project.this.name
  description = "CodeBuild project name"
}