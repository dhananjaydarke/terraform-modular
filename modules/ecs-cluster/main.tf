terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_cloudwatch_log_groups" "container_insights" {
  log_group_name_prefix = "/aws/ecs/containerinsights/${var.name}/performance"
}

locals {
  container_insights_log_group_exists = contains(
    data.aws_cloudwatch_log_groups.container_insights.log_group_names,
    "/aws/ecs/containerinsights/${var.name}/performance"
  )
}

/*
data "aws_cloudwatch_log_groups" "container_insights" {
  log_group_name_prefix = "/aws/ecs/containerinsights/${var.name}/performance"
}

locals {
  container_insights_log_group_exists = length(data.aws_cloudwatch_log_groups.container_insights.log_group_names) > 0
}
*/
resource "aws_cloudwatch_log_group" "container_insights" {
  count             = var.enable_container_insights && var.manage_container_insights_log_group && !local.container_insights_log_group_exists ? 1 : 0
  name              = "/aws/ecs/containerinsights/${var.name}/performance"
  retention_in_days = var.container_insights_log_retention_days
  tags              = var.tags
}

resource "aws_ecs_cluster" "this" {
  name = var.name
  depends_on = [aws_cloudwatch_log_group.container_insights]
  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(var.tags, { Name = var.name })
}

output "id" {
  value       = aws_ecs_cluster.this.id
  description = "ECS cluster ID"
}

output "arn" {
  value       = aws_ecs_cluster.this.arn
  description = "ECS cluster ARN"
}
