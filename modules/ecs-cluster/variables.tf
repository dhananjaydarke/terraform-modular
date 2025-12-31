variable "name" {
  description = "ECS cluster name"
  type        = string
}

variable "enable_container_insights" {
  description = "Toggle ECS Container Insights"
  type        = bool
  default     = true
}

variable "container_insights_log_retention_days" {
  description = "Retention in days for Container Insights log groups"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
