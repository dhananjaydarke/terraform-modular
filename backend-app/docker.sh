#!/bin/bash


export AWS_DEFAULT_REGION="us-east-1"
export IMAGE_TAG="latest"
export REPO_NAME="students-backend"
export ECR_REPO_URL="437147519305.dkr.ecr.us-east-1.amazonaws.com/${REPO_NAME}"

# Attempt to describe the repository
if aws ecr describe-repositories --repository-names "${REPO_NAME}" >/dev/null 2>&1; then
    echo "Repository '${REPO_NAME}' already exists."
else
    echo "Repository '${REPO_NAME}' does not exist. Creating it now..."
    aws ecr create-repository --repository-name "${REPO_NAME}"
    echo "Repository '${REPO_NAME}' created."
fi

aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${ECR_REPO_URL}
docker build --platform="linux/amd64" -t $ECR_REPO_URL:$IMAGE_TAG .
docker push $ECR_REPO_URL:$IMAGE_TAG






#aws ecs run-task \
#  --cluster arn:aws:ecs:us-east-1:437147519305:cluster/students-cluster \
#  --launch-type FARGATE \
#  --task-definition arn:aws:ecs:us-east-1:437147519305:task-definition/students-backend:10 \
# --network-configuration "awsvpcConfiguration={subnets=[subnet-00aa1e8099c66f121,subnet-028a8b364a57f13b9],securityGroups=[sg-0eed6d4de55613535],assignPublicIp=DISABLED}" \
#  --overrides 'containerOverrides=[{
#    name="students-backend",
#    environment=[
#      {name="DB_HOST",value="students-db.calmsi4iwo2e.us-east-1.rds.amazonaws.com"},
#      {name="DB_PORT",value="1433"},
#      {name="DB_NAME",value="students-db"},
#      {name="DB_USER",value="<db-user>"},
#      {name="DB_PASSWORD",value="<db-password>"}
#    ]
#  }]'

