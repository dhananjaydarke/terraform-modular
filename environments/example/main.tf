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
  subnet_ids       = module.network.public_subnet_ids
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
