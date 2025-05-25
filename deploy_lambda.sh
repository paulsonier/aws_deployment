#!/bin/bash

# Script to deploy an AWS Lambda function

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$LAMBDA_FUNCTION_NAME" ] || \
   [ -z "$LAMBDA_RUNTIME" ] || \
   [ -z "$LAMBDA_HANDLER" ] || \
   [ -z "$LAMBDA_S3_BUCKET" ] || \
   [ -z "$LAMBDA_S3_KEY" ] || \
   [ -z "$LAMBDA_ROLE_ARN" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, LAMBDA_FUNCTION_NAME, LAMBDA_RUNTIME, LAMBDA_HANDLER, LAMBDA_S3_BUCKET, LAMBDA_S3_KEY, and LAMBDA_ROLE_ARN."
  exit 1
fi

echo "Attempting to deploy Lambda function: $LAMBDA_FUNCTION_NAME"

# Check if the Lambda function already exists
aws lambda get-function --function-name "$LAMBDA_FUNCTION_NAME" --region "$AWS_DEFAULT_REGION" &> /dev/null

if [ $? -eq 0 ]; then
  echo "Lambda function '$LAMBDA_FUNCTION_NAME' already exists. Updating code and configuration."
  # Update function code
  aws lambda update-function-code \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --s3-bucket "$LAMBDA_S3_BUCKET" \
    --s3-key "$LAMBDA_S3_KEY" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager

  # Update function configuration (e.g., runtime, handler, role)
  aws lambda update-function-configuration \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --runtime "$LAMBDA_RUNTIME" \
    --handler "$LAMBDA_HANDLER" \
    --role "$LAMBDA_ROLE_ARN" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
else
  echo "Lambda function '$LAMBDA_FUNCTION_NAME' does not exist. Creating new function."
  # Create new function
  aws lambda create-function \
    --function-name "$LAMBDA_FUNCTION_NAME" \
    --runtime "$LAMBDA_RUNTIME" \
    --role "$LAMBDA_ROLE_ARN" \
    --handler "$LAMBDA_HANDLER" \
    --code S3Bucket="$LAMBDA_S3_BUCKET",S3Key="$LAMBDA_S3_KEY" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
fi

if [ $? -eq 0 ]; then
  echo "Lambda function '$LAMBDA_FUNCTION_NAME' deployment initiated successfully."
  echo "You can monitor its status using: aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --region $AWS_DEFAULT_REGION"
else
  echo "Failed to deploy Lambda function '$LAMBDA_FUNCTION_NAME'."
  exit 1
fi