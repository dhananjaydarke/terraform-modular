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
  tags = merge(var.tags, { Name = "${var.name}-task-execution" })
}

resource "aws_iam_role_policy_attachment" "execution_managed" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "task" {
  name               = "${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume.json
  tags = merge(var.tags, { Name = "${var.name}-task" })
}

resource "aws_iam_role_policy" "task_inline" {
  count = length(var.task_inline_policies) > 0 ? 1 : 0
  name  = "${var.name}-task-inline"
  role  = aws_iam_role.task.id
  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = var.task_inline_policies
  })
}

output "task_execution_role_arn" {
  value       = aws_iam_role.task_execution.arn
  description = "Execution role ARN"
}

output "task_role_arn" {
  value       = aws_iam_role.task.arn
  description = "Task role ARN"

}
