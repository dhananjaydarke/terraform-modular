terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_iam_policy_document" "task_execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name}-task-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
  tags               = merge(var.tags, { Name = "${var.name}-task-execution" })
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "task_execution_inline" {
  count = length(var.task_execution_inline_policies) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.task_execution_inline_policies
    content {
      sid       = try(statement.value.Sid, null)
      effect    = statement.value.Effect
      actions   = statement.value.Action
      resources = statement.value.Resource
    }
  }
}

resource "aws_iam_role_policy" "task_execution_inline" {
  count  = length(var.task_execution_inline_policies) > 0 ? 1 : 0
  name   = "${var.name}-task-execution-inline"
  role   = aws_iam_role.task_execution.id
  policy = data.aws_iam_policy_document.task_execution_inline[0].json  
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
  tags               = merge(var.tags, { Name = "${var.name}-task" })
}

data "aws_iam_policy_document" "task_inline" {
  count = length(var.task_inline_policies) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.task_inline_policies
    content {
      sid       = try(statement.value.Sid, null)
      effect    = statement.value.Effect
      actions   = statement.value.Action
      resources = statement.value.Resource
    }
  }
}

resource "aws_iam_role_policy" "task_inline" {
  count = length(var.task_inline_policies) > 0 ? 1 : 0
  name  = "${var.name}-task-inline"
  role  = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_inline[0].json  
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "Execution role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "Task role ARN"

}
