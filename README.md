# Modular Terraform layout for ECS + RDS + CloudFront/S3

This folder provides a composable Terraform layout that separates responsibilities by module:

- `modules/network`: VPC with public/private subnets, IGW/NAT, and routing.
- `modules/ecr`: ECR repository with lifecycle policy.
- `modules/ecs-cluster`: ECS cluster with optional Container Insights.
- `modules/ecs-roles`: Execution + task IAM roles for ECS tasks.
- `modules/nlb`: Network Load Balancer, target group, and listener for the backend.
- `modules/ecs-fargate-service`: Fargate task definition + service, security group, and logs.
- `modules/eventbridge-ecs-task`: EventBridge schedule to run an ECS task (e.g., DB poller).
- `modules/static-site`: Private S3 bucket with OAC-backed CloudFront distribution for static assets.
- `modules/rds`: RDS instance with subnet group and security group.
- `modules/codebuild-backend`: CodeBuild project to build and push backend image to ECR.
- `modules/codebuild-frontend`: CodeBuild project to build and deploy the frontend to S3/CloudFront.

An example environment composition lives in `environments/example`, wiring these modules together for a backend API service, scheduled DB fetcher, and static site CDN.

## Usage (example environment)

```bash
cd environments/example
terraform init
terraform plan \
  -var db_name=appdb -var db_user=appuser -var db_password=secret-value
terraform apply # when ready
```

Adjust variables in `environments/example/variables.tf` for ports, names, or database connection details. Swap the `db_fetch_image` to your own poller image. The backend image is expected to be pushed to the created ECR repo (`backend_repo_url` output).

## Notes
- The load balancer module is configured as an NLB (TCP) for simplicity. Swap to an ALB by extending or replacing the module if you need HTTP features (WAF at the edge, advanced health checks, host/path routing).
- The example RDS defaults to PostgreSQL on port 5432; adjust `db_engine`, `db_engine_version`, `db_instance_class`, `db_allocated_storage`, and `db_port` as needed.