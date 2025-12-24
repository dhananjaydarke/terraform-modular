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

variable "db_host" {
  description = "Database endpoint"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_fetch_image" {
  description = "Image URI for the DB fetch/task runner"
  type        = string
  default     = "mcr.microsoft.com/mssql-tools"
}

variable "private_api_stage_name" {
  description = "Stage name for the private API Gateway"
  type        = string
  default     = "v1"
}

variable "private_hosted_zone_name" {
  description = "Private hosted zone name for internal DNS"
  type        = string
  default     = "internal.local"
}
