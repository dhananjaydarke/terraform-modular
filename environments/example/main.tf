terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project = "students-app"
    Env     = var.environment
  }
}

module "network" {
  source   = "../../modules/network"
  name     = "${var.name_prefix}-net"
  vpc_cidr = var.vpc_cidr
  az_count = 2
  tags     = local.common_tags
}

module "ecr_backend" {
  source                  = "../../modules/ecr"
  name                    = "${var.name_prefix}-backend"
  untagged_retention_days = 30
  tags                    = local.common_tags
}

module "ecs_cluster" {
  source                   = "../../modules/ecs-cluster"
  name                     = "${var.name_prefix}-cluster"
  enable_container_insights = true
  tags                     = local.common_tags
}

module "ecs_roles" {
  source               = "../../modules/ecs-roles"
  name                 = "${var.name_prefix}-ecs"
  task_inline_policies = []
  tags                 = local.common_tags
}

module "lb" {
  source           = "../../modules/nlb"
  name             = "${var.name_prefix}-nlb"
  vpc_id           = module.network.vpc_id
  subnet_ids       = module.network.private_subnet_ids
  internal         = true
  target_port      = var.backend_port
  target_protocol  = "TCP"
  listener_port    = 80
  listener_protocol = "TCP"
  health_check = {
    protocol            = "TCP"
    port                = tostring(var.backend_port)
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
  tags = local.common_tags
}

resource "aws_security_group" "api_gateway_endpoint" {
  name        = "${var.name_prefix}-execute-api-endpoint"
  description = "Allow private API Gateway endpoint access"
  vpc_id      = module.network.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.network.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_vpc_endpoint" "execute_api" {
  vpc_id              = module.network.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.network.private_subnet_ids
  security_group_ids  = [aws_security_group.api_gateway_endpoint.id]
  private_dns_enabled = true
  tags                = local.common_tags
}

data "aws_iam_policy_document" "private_api_policy" {
  statement {
    sid     = "AllowInvokeFromVpcEndpoint"
    actions = ["execute-api:Invoke"]
    effect  = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["arn:aws:execute-api:${var.aws_region}:*:*/*/*/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.execute_api.id]
    }
  }
}

resource "aws_api_gateway_rest_api" "private_api" {
  name = "${var.name_prefix}-private-api"
  endpoint_configuration {
    types = ["PRIVATE"]
  }
  policy = data.aws_iam_policy_document.private_api_policy.json
  tags   = local.common_tags
}

resource "aws_api_gateway_vpc_link" "private_api" {
  name        = "${var.name_prefix}-vpc-link"
  target_arns = [module.lb.lb_arn]
  tags        = local.common_tags
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id
  parent_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "root_any" {
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_rest_api.private_api.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root_any" {
  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_rest_api.private_api.root_resource_id
  http_method             = aws_api_gateway_method.root_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.private_api.id
  uri                     = "http://${module.lb.lb_dns_name}"
}

resource "aws_api_gateway_method" "proxy_any" {
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "proxy_any" {
  rest_api_id             = aws_api_gateway_rest_api.private_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_any.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "ANY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.private_api.id
  uri                     = "http://${module.lb.lb_dns_name}/{proxy}"
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_deployment" "private_api" {
  rest_api_id = aws_api_gateway_rest_api.private_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.root_any.id,
      aws_api_gateway_method.proxy_any.id,
      aws_api_gateway_integration.root_any.id,
      aws_api_gateway_integration.proxy_any.id,
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.root_any,
    aws_api_gateway_integration.proxy_any,
  ]
}

resource "aws_api_gateway_stage" "private_api" {
  rest_api_id   = aws_api_gateway_rest_api.private_api.id
  deployment_id = aws_api_gateway_deployment.private_api.id
  stage_name    = var.private_api_stage_name
  tags          = local.common_tags
}

resource "aws_wafv2_web_acl" "private_api" {
  name  = "${var.name_prefix}-private-api-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-private-api-common"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-private-api"
    sampled_requests_enabled   = true
  }

  tags = local.common_tags
}

resource "aws_wafv2_web_acl_association" "private_api" {
  resource_arn = aws_api_gateway_stage.private_api.arn
  web_acl_arn  = aws_wafv2_web_acl.private_api.arn
}

resource "aws_route53_zone" "private" {
  name = var.private_hosted_zone_name
  vpc {
    vpc_id = module.network.vpc_id
  }
  tags = local.common_tags
}

resource "aws_route53_record" "private_nlb" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "backend.${var.private_hosted_zone_name}"
  type    = "A"
  alias {
    name                   = module.lb.lb_dns_name
    zone_id                = module.lb.lb_zone_id
    evaluate_target_health = false
  }
}

module "backend_service" {
  source                = "../../modules/ecs-fargate-service"
  name                  = "${var.name_prefix}-backend"
  cluster_id            = module.ecs_cluster.id
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.private_subnet_ids
  task_execution_role_arn = module.ecs_roles.task_execution_role_arn
  task_role_arn           = module.ecs_roles.task_role_arn
  container_name        = "backend"
  container_image       = "${module.ecr_backend.repository_url}:latest"
  container_port        = var.backend_port
  aws_region            = var.aws_region
  target_group_arn      = module.lb.target_group_arn
  desired_count         = 2
  cpu                   = 256
  memory                = 512
  environment = {
    DB_HOST = var.db_host
    DB_PORT = tostring(var.db_port)
    DB_NAME = var.db_name
    DB_USER = var.db_user
    DB_PASSWORD = var.db_password
  }
  ingress_rules = [
    {
      from_port   = var.backend_port
      to_port     = var.backend_port
      protocol    = "tcp"
      cidr_blocks = [module.network.vpc_cidr]
      description = "From VPC"
    }
  ]
  tags = local.common_tags
}

module "db_fetch_task" {
  source                  = "../../modules/ecs-fargate-service"
  name                    = "${var.name_prefix}-db-fetch"
  cluster_id              = module.ecs_cluster.id
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.private_subnet_ids
  task_execution_role_arn = module.ecs_roles.task_execution_role_arn
  task_role_arn           = module.ecs_roles.task_role_arn
  container_name          = "db-fetch"
  container_image         = var.db_fetch_image
  container_port          = 8080
  aws_region              = var.aws_region
  desired_count           = 0
  target_group_arn        = null
  ingress_rules           = []
  environment = {
    DB_HOST = var.db_host
    DB_PORT = tostring(var.db_port)
    DB_NAME = var.db_name
    DB_USER = var.db_user
    DB_PASSWORD = var.db_password
  }
  tags = local.common_tags
}

module "db_fetch_schedule" {
  source               = "../../modules/eventbridge-ecs-task"
  name                 = "${var.name_prefix}-db-fetch"
  schedule_expression  = "rate(5 minutes)"
  cluster_arn          = module.ecs_cluster.arn
  task_definition_arn  = module.db_fetch_task.task_definition_arn
  subnet_ids           = module.network.private_subnet_ids
  security_group_ids   = [module.db_fetch_task.security_group_id]
  pass_role_arns       = [module.ecs_roles.task_execution_role_arn, module.ecs_roles.task_role_arn]
  tags                 = local.common_tags
}

module "static_site" {
  source       = "../../modules/static-site"
  bucket_name  = "${var.name_prefix}-static-${var.environment}"
  tags         = local.common_tags
  depends_on   = [module.network]
}
