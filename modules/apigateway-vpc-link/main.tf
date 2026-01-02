terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = "HTTP"
  tags          = merge(var.tags, { Name = var.name })
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.name}-vpc-link"
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  tags               = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_uri        = var.integration_uri
  integration_method     = "ANY"
  payload_format_version = "1.0"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.this.id
  timeout_milliseconds   = 30000
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage_name
  auto_deploy = true
  tags        = var.tags
}

output "api_id" {
  value       = aws_apigatewayv2_api.this.id
  description = "API Gateway ID"
}

output "api_endpoint" {
  value       = aws_apigatewayv2_api.this.api_endpoint
  description = "API Gateway endpoint"
}

output "api_domain_name" {
  value       = replace(aws_apigatewayv2_api.this.api_endpoint, "https://", "")
  description = "API Gateway domain name"
}

output "stage_name" {
  value       = aws_apigatewayv2_stage.this.name
  description = "API Gateway stage name"
}
