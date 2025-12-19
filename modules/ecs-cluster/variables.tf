variable "name" {
  description = "ECS cluster name"
  type        = string
}

variable "enable_container_insights" {
  description = "Toggle ECS Container Insights"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
