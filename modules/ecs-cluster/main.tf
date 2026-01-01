terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_ecs_cluster" "this" {
  name = var.name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_cloudwatch_log_group" "container_insights" {
  count             = var.enable_container_insights ? 1 : 0
  name              = "/aws/ecs/containerinsights/${var.name}/performance"
  retention_in_days = var.container_insights_log_retention_days
  tags              = var.tags
}

output "id" {
  value       = aws_ecs_cluster.this.id
  description = "ECS cluster ID"
}

output "arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ECS cluster ARN"
}
