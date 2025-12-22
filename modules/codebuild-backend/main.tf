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
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage"
        ]
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
  description  = "Build and push backend image to ECR"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "ECR_REPO_URL"
      value = var.ecr_repo_url
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
/*
  dynamic "source_version" {
    for_each = var.github_branch != "" ? [var.github_branch] : []
    content  = source_version.value
  }
*/
  source_version = var.github_branch  
  tags = merge(var.tags, { Name = var.name })  

}

output "project_name" {
  value       = aws_codebuild_project.this.name
  description = "CodeBuild project name"
}
