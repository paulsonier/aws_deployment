#!/bin/bash

# Script to test S3 bucket deletion permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$TEST_S3_BUCKET_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and TEST_S3_BUCKET_NAME."
  exit 1
fi

echo "Testing S3 bucket deletion permissions for bucket: $TEST_S3_BUCKET_NAME"

# Attempt to create a bucket first, then try to delete it
TEMP_BUCKET_NAME="${TEST_S3_BUCKET_NAME}-delete-test-$(date +%s)"

echo "Attempting to create temporary bucket: $TEMP_BUCKET_NAME"
aws s3api create-bucket \
  --bucket "$TEMP_BUCKET_NAME" \
  --region "$AWS_DEFAULT_REGION" \
  --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -ne 0 ]; then
  echo "WARNING: Could not create temporary bucket '$TEMP_BUCKET_NAME'. Cannot fully test delete permissions without a bucket to delete."
  echo "Please ensure you have create permissions for S3 buckets to run this test effectively."
  exit 1
fi

echo "Temporary bucket '$TEMP_BUCKET_NAME' created. Attempting to delete it."

aws s3api delete-bucket \
  --bucket "$TEMP_BUCKET_NAME" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to delete S3 buckets."
  exit 0
else
  echo "FAILURE: User does NOT have permissions to delete S3 buckets."
  exit 1
fi