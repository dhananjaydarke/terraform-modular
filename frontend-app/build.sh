#!/bin/bash  
export API_BASE_URL="students-nlb-fd6b80388143f090.elb.us-east-1.amazonaws.com:8080"
export DISTRIBUTION_ID="EAHB9ORW8A6US"
export BUCKET_NAME="students-static-dev"
API_BASE_URL=$API_BASE_URL npm run build  
aws s3 sync dist/ s3://$BUCKET_NAME/ --delete --cache-control max-age=300
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
