variable "name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "force_delete" {
  description = "Allow force deletion of the repository"
  type        = bool
  default     = true
}

variable "untagged_retention_days" {
  description = "Retention in days for untagged images"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
