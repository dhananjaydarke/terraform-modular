variable "name" {
  description = "API Gateway name"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the VPC link"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for the VPC link"
  type        = list(string)
  default     = []
}

variable "integration_uri" {
  description = "Integration URI (e.g., NLB listener ARN)"
  type        = string
}

variable "route_key" {
  description = "Route key for the API Gateway route"
  type        = string
  default     = "ANY /api/{proxy+}"
}

variable "stage_name" {
  description = "Stage name for the API Gateway"
  type        = string
  default     = "$default"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
