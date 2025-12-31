#!/bin/bash
export IMAGE_TAG="latest"
export AWS_DEFAULT_REGION="us-east-1"
export REPO_NAME="students-db-seed"
export ECR_REPO_URL="437147519305.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}"

export DB_PORT="5432"
export DB_USER="students_admin"  
export DB_PASSWORD="students_admin123$" 
export DB_NAME="appdb"
export DB_HOST="students-db.calmsi4iwo2e.us-east-1.rds.amazonaws.com"
#aws ecr create-repository --repository-name students-db-seed || true
if aws ecr describe-repositories --repository-names "${REPO_NAME}" >/dev/null 2>&1; then
    echo "Repository '${REPO_NAME}' already exists."
else
    echo "Repository '${REPO_NAME}' does not exist. Creating it now..."
    aws ecr create-repository --repository-name "${REPO_NAME}"
    echo "Repository '${REPO_NAME}' created."
fi
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${ECR_REPO_URL}
docker build --platform="linux/amd64" -t  $ECR_REPO_URL:$IMAGE_TAG .
docker push $ECR_REPO_URL:$IMAGE_TAG


aws ecs run-task \
  --cluster "arn:aws:ecs:us-east-1:437147519305:cluster/students-cluster" \
  --launch-type "FARGATE" \
  --task-definition "arn:aws:ecs:us-east-1:437147519305:task-definition/students-db-fetch" \
 --network-configuration "awsvpcConfiguration={subnets=[subnet-035a41d9280e0c0f5,subnet-0358f6086c92b8a73],securityGroups=[sg-0e55da11050839681],assignPublicIp=DISABLED}" \
  --overrides 'containerOverrides=[{
    name="db-fetch",
    environment=[
      {name="DB_HOST",value="students-db.calmsi4iwo2e.us-east-1.rds.amazonaws.com"},
      {name="DB_PORT",value="5432"},
      {name="DB_NAME",value="appdb"},
      {name="DB_USER",value="students_admin"},
      {name="DB_PASSWORD",value="students_admin123$"}
    ]
  }]'
