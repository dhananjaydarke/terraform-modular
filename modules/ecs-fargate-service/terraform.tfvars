name                  = "example-fargate-service"
cluster_id            = "example-ecs-cluster-id"
vpc_id                = "vpc-0123456789abcdef0"
subnet_ids            = ["subnet-aaa111bbb", "subnet-ccc222ddd"]

# IAM role ARNs used by your tasks
# Replace these with the roles provisioned for your environment
task_execution_role_arn = "arn:aws:iam::123456789012:role/example-ecs-task-execution"
task_role_arn           = "arn:aws:iam::123456789012:role/example-ecs-task"

container_name  = "app"
container_image = "public.ecr.aws/docker/library/nginx:latest"
container_port  = 8080
aws_region      = "us-east-1"

# Optional values shown here for convenience
desired_count = 2
cpu           = 256
memory        = 512
assign_public_ip = false

environment = {
  EXAMPLE_KEY = "example-value"
}

target_group_arn = null

# Ingress rules to allow traffic to the service
ingress_rules = [
  {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "Allow traffic from VPC"
  }
]

tags = {
  Project = "demo"
  Env     = "dev"
}
