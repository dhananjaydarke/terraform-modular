variable "name" {
  description = "Prefix for IAM role names"
  type        = string
}

variable "task_inline_policies" {
  description = "Inline policy statements to attach to the task role"
  type = list(object({
    Effect    = string
    Action    = list(string)
    Resource  = list(string)
    Sid       = optional(string)
    Condition = optional(map(any))
  }))
  default = []
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

