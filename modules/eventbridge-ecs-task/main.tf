terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-events"
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge(var.tags, { Name = "${var.name}-events" })
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask", "ecs:DescribeTasks"]
    resources = [var.task_definition_arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = var.pass_role_arns
  }
}

resource "aws_iam_role_policy" "this" {
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = "${var.name}-rule"
  schedule_expression = var.schedule_expression
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "${var.name}-target"
  arn       = var.cluster_arn
  role_arn  = aws_iam_role.this.arn

  ecs_target {
    task_definition_arn = var.task_definition_arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = false
    }
  }
}

output "rule_arn" {
  value       = aws_cloudwatch_event_rule.this.arn
  description = "EventBridge rule ARN"
}
