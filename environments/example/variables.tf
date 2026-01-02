variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "students"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "backend_port" {
  description = "Backend service port"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_user" {
  description = "Master username"
  type        = string
  default     = "students_admin"
}

variable "db_password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default     = "students_admin123$"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "16.3"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage (GB)"
  type        = number
  default     = 20
}

variable "db_fetch_image" {
  description = "Image URI for the DB fetch/task runner"
  type        = string
  default     = ""
}

variable "db_engine" {
  description = "Database engine (e.g., postgres, mysql)"
  type        = string
  default     = "postgres"
}
variable "backend_github_repo" {
  description = "GitHub HTTPS URL for backend source"
  type        = string
  default     = "https://github.com/dhananjaydarke/terraform-modular"
}

variable "backend_github_branch" {
  description = "Backend branch"
  type        = string
  default     = "origin/origin/codex/update-backend-to-use-postgresql"
}

variable "frontend_github_repo" {
  description = "GitHub HTTPS URL for frontend source"
  type        = string
  default     = "https://github.com/dhananjaydarke/terraform-modular"
}

variable "frontend_github_branch" {
  description = "Frontend branch"
  type        = string
  default     = "origin/origin/codex/update-backend-to-use-postgresql"
}

variable "frontend_api_base_url" {
  description = "API base URL to inject at frontend build time"
  type        = string
  default     = "/api"
}

variable "cloudfront_domain_name" {
  description = "Custom domain name for CloudFront (optional)"
  type        = string
  default     = ""
}

variable "cloudfront_aliases" {
  description = "Alternate domain names for CloudFront"
  type        = list(string)
  default     = []
}

variable "cloudfront_hosted_zone_id" {
  description = "Route53 hosted zone ID for CloudFront certificate validation (optional)"
  type        = string
  default     = ""
}
