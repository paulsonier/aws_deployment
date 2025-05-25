#!/bin/bash

# Script to test S3 bucket deployment permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$TEST_S3_BUCKET_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and TEST_S3_BUCKET_NAME."
  exit 1
fi

echo "Testing S3 bucket deployment permissions for bucket: $TEST_S3_BUCKET_NAME"

# Attempt to create a bucket with a unique name to avoid conflicts
TEMP_BUCKET_NAME="${TEST_S3_BUCKET_NAME}-test-$(date +%s)"

aws s3api create-bucket \
  --bucket "$TEMP_BUCKET_NAME" \
  --region "$AWS_DEFAULT_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to deploy S3 buckets."
  # Clean up the temporary bucket
  echo "Cleaning up temporary bucket: $TEMP_BUCKET_NAME"
  aws s3api delete-bucket --bucket "$TEMP_BUCKET_NAME" --region "$AWS_DEFAULT_REGION" --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Temporary bucket '$TEMP_BUCKET_NAME' deleted successfully."
  else
    echo "WARNING: Failed to delete temporary bucket '$TEMP_BUCKET_NAME'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to deploy S3 buckets."
  exit 1
fi