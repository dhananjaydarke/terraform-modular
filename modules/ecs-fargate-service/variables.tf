variable "name" {
  description = "Service name prefix"
  type        = string
}

variable "cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "task_role_arn" {
  description = "ECS task role ARN"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the service"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "desired_count" {
  description = "Desired task count"
  type        = number
  default     = 2
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory (MB)"
  type        = number
  default     = 512
}

variable "container_name" {
  description = "Container name"
  type        = string
}

variable "container_image" {
  description = "Container image URI"
  type        = string
}

variable "container_port" {
  description = "Application port"
  type        = number
  default     = 8080
}

variable "container_entrypoint" {
  description = "Optional container entrypoint override"
  type        = list(string)
  default     = null
}

variable "container_command" {
  description = "Optional container command override"
  type        = list(string)
  default     = null
}

variable "container_protocol" {
  description = "Container protocol"
  type        = string
  default     = "tcp"
}

variable "environment" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "target_group_arn" {
  description = "Optional target group to register"
  type        = string
  default     = null
}

variable "ingress_rules" {
  description = "Ingress rules for the service security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = []
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention"
  type        = number
  default     = 7
}

variable "aws_region" {
  description = "AWS region (for logs)"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
