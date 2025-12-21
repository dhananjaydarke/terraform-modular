variable "name" {
  description = "Project name"
  type        = string
}

variable "github_repo" {
  description = "GitHub HTTPS URL to the frontend repo"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
  default     = "main"
}

variable "bucket_name" {
  description = "S3 bucket for frontend assets"
  type        = string
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID to invalidate"
  type        = string
}

variable "api_base_url" {
  description = "API base URL injected at build time"
  type        = string
}

variable "buildspec" {
  description = "Optional custom buildspec"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}