#!/bin/bash  
export API_BASE_URL="d2uyuz7drzef9l.cloudfront.net"
export DISTRIBUTION_ID="E2B7OJ2ZX6UMB"
export BUCKET_NAME="students-static-dev"
API_BASE_URL=$API_BASE_URL npm run build  
aws s3 sync dist/ s3://$BUCKET_NAME/ --delete --cache-control max-age=300
aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
