variable "name" {
  description = "Identifier prefix for the RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine (e.g., postgres, mysql)"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Engine version"
  type        = string
  default     = "16.3"
}

variable "instance_class" {
  description = "Instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "username" {
  description = "Master username"
  type        = string
  default = "students_admin"  
}

variable "password" {
  description = "Master password"
  type        = string
  sensitive   = true
  default = "students_admin123$"    
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default = "appdb"
}

variable "port" {
  description = "Database port"
  type        = number
  default     = 5432
}

variable "subnet_ids" {
  description = "Subnets for the DB subnet group (private subnets)"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the DB"
  type        = list(string)
  default     = []
}

variable "multi_az" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
  }
