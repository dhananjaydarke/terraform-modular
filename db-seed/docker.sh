#!/bin/bash
export AWS_DEFAULT_REGION="us-east-1"
export IMAGE_TAG="latest"
export AWS_DEFAULT_REGION="us-east-1"
export ECR_REPO_URL="437147519305.dkr.ecr.us-east-1.amazonaws.com/students-db-seed"

export DB_PORT="5432"  
export DB_USER="students_admin"  
export DB_PASSWORD="students_admin123$" 
export DB_NAME="StudentsDB"
export DB_HOST="students-db.calmsi4iwo2e.us-east-1.rds.amazonaws.com"
aws ecr create-repository --repository-name students-db-seed || true
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${ECR_REPO_URL}
docker build --platform="linux/amd64" -t  $ECR_REPO_URL:$IMAGE_TAG .
docker push $ECR_REPO_URL:$IMAGE_TAG


aws ecs run-task \
  --cluster "arn:aws:ecs:us-east-1:437147519305:cluster/students-cluster" \
  --launch-type "FARGATE" \
  --task-definition "arn:aws:ecs:us-east-1:437147519305:task-definition/students-db-fetch" \
 --network-configuration "awsvpcConfiguration={subnets=[subnet-0b0754c6f0b2624b3,subnet-0ae2669de06d7cb61],securityGroups=[sg-05db42b33ff52fadc],assignPublicIp=DISABLED}" \
  --overrides 'containerOverrides=[{
    name="db-fetch",
    environment=[
      {name="DB_HOST",value="students-db.calmsi4iwo2e.us-east-1.rds.amazonaws.com"},
      {name="DB_PORT",value="1433"},
      {name="DB_NAME",value="students-db"},
      {name="DB_USER",value="students_admin"},
      {name="DB_PASSWORD",value="students_admin123$"}
    ]
  }]'

