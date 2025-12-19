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
