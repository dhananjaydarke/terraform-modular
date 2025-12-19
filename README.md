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

An example environment composition lives in `environments/example`, wiring these modules together for a backend API service, scheduled DB fetcher, and static site CDN.

## Usage (example environment)

```bash
cd environments/example
terraform init
terraform plan -var db_host=example.cluster-abcdef.us-east-1.rds.amazonaws.com \
  -var db_name=appdb -var db_user=appuser -var db_password=secret-value
terraform apply # when ready
```

Adjust variables in `environments/example/variables.tf` for ports, names, or database connection details. Swap the `db_fetch_image` to your own poller image. The backend image is expected to be pushed to the created ECR repo (`backend_repo_url` output).

## Notes
- The load balancer module is configured as an NLB (TCP) for simplicity. Swap to an ALB by extending or replacing the module if you need HTTP features (WAF at the edge, advanced health checks, host/path routing).
- The example keeps state local for clarity; point the backend to S3/DynamoDB for team usage.
- Tagging is centralized via `local.common_tags` in the example composition.