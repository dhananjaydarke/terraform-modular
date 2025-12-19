variable "name" {
  description = "Name prefix for the NLB and target group"
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "internal" {
  description = "Whether the NLB is internal"
  type        = bool
  default     = false
}

variable "listener_port" {
  description = "Listener port"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Listener protocol"
  type        = string
  default     = "TCP"
}

variable "target_port" {
  description = "Target port"
  type        = number
}

variable "target_protocol" {
  description = "Target protocol"
  type        = string
  default     = "TCP"
}

variable "health_check" {
  description = "Optional health check configuration"
  type = object({
    protocol            = optional(string)
    port                = optional(string)
    healthy_threshold   = optional(number)
    unhealthy_threshold = optional(number)
    interval            = optional(number)
    timeout             = optional(number)
    path                = optional(string)
    matcher             = optional(string)
  })
  default = null
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
