output "vpc_id" {
  value       = module.network.vpc_id
  description = "VPC identifier"
}

output "public_subnet_ids" {
  value       = module.network.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Private subnet IDs"
}

output "backend_repo_url" {
  value       = module.ecr_backend.repository_url
  description = "ECR repository URL"
}

output "backend_lb_dns" {
  value       = module.lb.lb_dns_name
  description = "Network Load Balancer DNS"
}

output "frontend_domain" {
  value       = module.static_site.distribution_domain
  description = "CloudFront distribution domain"
}
output "db_endpoint" {
  value       = module.rds.endpoint
  description = "RDS endpoint"
}

output "frontend_distribution_id" {
  value       = module.static_site.distribution_id
  description = "CloudFront distribution ID"
}

output "frontend_api_base_url" {
  value       = "http://${module.lb.lb_dns_name}:${var.backend_port}/api"
  description = "API base URL for the frontend build"
}

output "db_port" {
  value       = module.rds.port
  description = "RDS port"
}

output "db_subnet_ids" {
  value       = module.network.private_subnet_ids
  description = "Database subnet IDs"
}

output "db_security_group_id" {
  value       = module.rds.security_group_id
  description = "Database security group ID"
}