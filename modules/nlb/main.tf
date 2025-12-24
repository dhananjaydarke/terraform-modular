terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "network"
  internal           = var.internal
  subnets            = var.subnet_ids
  tags               = merge(var.tags, { Name = var.name })
}

resource "aws_lb_target_group" "this" {
  name        = "${var.name}-tg"
  port        = var.target_port
  protocol    = var.target_protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  dynamic "health_check" {
    for_each = var.health_check != null ? [var.health_check] : []
    content {
      protocol            = lookup(health_check.value, "protocol", null)
      port                = lookup(health_check.value, "port", null)
      healthy_threshold   = lookup(health_check.value, "healthy_threshold", null)
      unhealthy_threshold = lookup(health_check.value, "unhealthy_threshold", null)
      interval            = lookup(health_check.value, "interval", null)
      timeout             = lookup(health_check.value, "timeout", null)
      path                = lookup(health_check.value, "path", null)
      matcher             = lookup(health_check.value, "matcher", null)
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-tg" })
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

output "lb_arn" {
  value       = aws_lb.this.arn
  description = "Load balancer ARN"
}

output "lb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Load balancer DNS name"
}

output "lb_zone_id" {
  value       = aws_lb.this.zone_id
  description = "Load balancer zone ID"
}

output "target_group_arn" {
  value       = aws_lb_target_group.this.arn
  description = "Target group ARN"
}
