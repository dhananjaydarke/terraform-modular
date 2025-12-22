#!/bin/bash


export IMAGE_TAG="latest"
export ECR_REPO_URL="437147519305.dkr.ecr.us-east-1.amazonaws.com/students-backend"
aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin ${ECR_REPO_URL}
docker build --platform=linux/amd64 -t $ECR_REPO_URL:$IMAGE_TAG .
docker push $ECR_REPO_URL:$IMAGE_TAG

