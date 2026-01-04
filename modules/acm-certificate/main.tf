terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method
  tags                      = merge(var.tags, { Name = var.domain_name })
}

resource "aws_route53_record" "validation" {
  for_each = var.enable_validation ? {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 300
}

resource "aws_acm_certificate_validation" "this" {
  count                   = var.enable_validation ? 1 : 0
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}

output "certificate_arn" {
  value       = aws_acm_certificate.this.arn
  description = "ACM certificate ARN"
}

output "validated_certificate_arn" {
  value       = var.enable_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
  description = "ACM certificate ARN after DNS validation (or raw ARN if validation disabled)"
}

output "certificate_arn_for_cloudfront" {
  value       = var.enable_validation ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this.arn
  description = "ACM certificate ARN to use for CloudFront (validated when DNS validation is enabled)"
}

output "validation_records" {
  value = [
    for dvo in aws_acm_certificate.this.domain_validation_options : {
      domain_name = dvo.domain_name
      name        = dvo.resource_record_name
      type        = dvo.resource_record_type
      value       = dvo.resource_record_value
    }
  ]
  description = "DNS validation records"
}
