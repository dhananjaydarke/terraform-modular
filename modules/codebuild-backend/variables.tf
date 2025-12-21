variable "name" {
  description = "Project name"
  type        = string
}

variable "github_repo" {
  description = "GitHub HTTPS URL to the backend repo"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch"
  type        = string
  default     = "main"
}

variable "ecr_repo_url" {
  description = "ECR repository URL to push"
  type        = string
}

variable "buildspec" {
  description = "Optional custom buildspec YAML"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}