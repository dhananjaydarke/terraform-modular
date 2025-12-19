variable "name" {
  description = "Name prefix for the schedule"
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression"
  type        = string
}

variable "cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

variable "task_definition_arn" {
  description = "Task definition ARN to run"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for running the task"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the task"
  type        = list(string)
}

variable "pass_role_arns" {
  description = "Roles EventBridge may pass (task and execution roles)"
  type        = list(string)
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
