#!/bin/bash

# This script deploys an S3 bucket.
# It depends on the following environment variables:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION
# S3_BUCKET_NAME

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_DEFAULT_REGION" ] || [ -z "$S3_BUCKET_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and S3_BUCKET_NAME."
  exit 1
fi

echo "Attempting to create S3 bucket: $S3_BUCKET_NAME in region: $AWS_DEFAULT_REGION"

aws s3api create-bucket --bucket "$S3_BUCKET_NAME" --region "$AWS_DEFAULT_REGION" --create-bucket-configuration LocationConstraint="$AWS_DEFAULT_REGION"

if [ $? -eq 0 ]; then
  echo "S3 bucket '$S3_BUCKET_NAME' created successfully."
else
  echo "Error creating S3 bucket '$S3_BUCKET_NAME'."
  exit 1
fi