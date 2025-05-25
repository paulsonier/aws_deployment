#!/bin/bash

# Script to test S3 bucket modification permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$EXISTING_S3_BUCKET_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and EXISTING_S3_BUCKET_NAME."
  exit 1
fi

echo "Testing S3 bucket modification permissions for bucket: $EXISTING_S3_BUCKET_NAME"

# Attempt to put a dummy bucket policy to test modify permissions
# Note: This requires an existing bucket.
# The policy grants read-only access to the bucket for a specific user (replace with a dummy ARN or your own for testing)
DUMMY_POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": {"AWS": "arn:aws:iam::123456789012:user/dummy-user"},
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'"$EXISTING_S3_BUCKET_NAME"'/*"
        }
    ]
}'

aws s3api put-bucket-policy \
  --bucket "$EXISTING_S3_BUCKET_NAME" \
  --policy "$DUMMY_POLICY" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to modify S3 buckets (e.g., put bucket policy)."
  # Attempt to delete the dummy policy to clean up
  echo "Attempting to delete dummy policy from bucket: $EXISTING_S3_BUCKET_NAME"
  aws s3api delete-bucket-policy \
    --bucket "$EXISTING_S3_BUCKET_NAME" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Dummy policy deleted successfully."
  else
    echo "WARNING: Failed to delete dummy policy from bucket '$EXISTING_S3_BUCKET_NAME'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to modify S3 buckets."
  exit 1
fi