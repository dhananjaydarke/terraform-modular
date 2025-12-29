terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-subnets"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-subnets" })
}

resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "RDS access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}

resource "aws_db_instance" "this" {
  identifier              = var.name
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  allocated_storage       = var.allocated_storage
  username                = var.username
  password                = var.password
  #  db_name                 = var.db_name
  port                    = var.port
  vpc_security_group_ids  = [aws_security_group.this.id]
  db_subnet_group_name    = aws_db_subnet_group.this.name
  multi_az                = var.multi_az
  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  apply_immediately       = true

  tags = merge(var.tags, { Name = var.name })
}

output "endpoint" {
  value       = aws_db_instance.this.address
  description = "RDS endpoint"
}

output "port" {
  value       = aws_db_instance.this.port
  description = "RDS port"
}

output "name" {
  value       = aws_db_instance.this.db_name
  description = "Database name"
}

output "username" {
  value       = aws_db_instance.this.username
  description = "Database username"
}

output "password" {
  value       = var.password
  description = "Database password (input)"
  sensitive   = true
}

output "security_group_id" {
  value       = aws_security_group.this.id
  description = "RDS security group ID"
}
