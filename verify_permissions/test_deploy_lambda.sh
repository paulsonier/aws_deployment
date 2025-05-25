#!/bin/bash

# Script to test Lambda function deployment permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$TEST_LAMBDA_FUNCTION_NAME" ] || \
   [ -z "$TEST_LAMBDA_RUNTIME" ] || \
   [ -z "$TEST_LAMBDA_HANDLER" ] || \
   [ -z "$TEST_LAMBDA_ROLE_ARN" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, TEST_LAMBDA_FUNCTION_NAME, TEST_LAMBDA_RUNTIME, TEST_LAMBDA_HANDLER, and TEST_LAMBDA_ROLE_ARN."
  exit 1
fi

echo "Testing Lambda function deployment permissions for function: $TEST_LAMBDA_FUNCTION_NAME"

# Create a dummy zip file for the Lambda code
DUMMY_ZIP_FILE="/tmp/dummy_lambda_code.zip"
echo "def handler(event, context): return {'statusCode': 200, 'body': 'Hello from Lambda!'}" > /tmp/lambda_function.py
zip -j "$DUMMY_ZIP_FILE" /tmp/lambda_function.py > /dev/null

# Attempt to create a dummy Lambda function
TEMP_LAMBDA_FUNCTION_NAME="${TEST_LAMBDA_FUNCTION_NAME}-test-$(date +%s)"

aws lambda create-function \
  --function-name "$TEMP_LAMBDA_FUNCTION_NAME" \
  --runtime "$TEST_LAMBDA_RUNTIME" \
  --role "$TEST_LAMBDA_ROLE_ARN" \
  --handler "$TEST_LAMBDA_HANDLER" \
  --zip-file "fileb://$DUMMY_ZIP_FILE" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to deploy Lambda functions."
  echo "Cleaning up temporary Lambda function: $TEMP_LAMBDA_FUNCTION_NAME"
  aws lambda delete-function \
    --function-name "$TEMP_LAMBDA_FUNCTION_NAME" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Temporary Lambda function '$TEMP_LAMBDA_FUNCTION_NAME' deleted successfully."
  else
    echo "WARNING: Failed to delete temporary Lambda function '$TEMP_LAMBDA_FUNCTION_NAME'. Manual cleanup may be required."
  fi
  rm -f /tmp/lambda_function.py "$DUMMY_ZIP_FILE"
  exit 0
else
  echo "FAILURE: User does NOT have permissions to deploy Lambda functions."
  rm -f /tmp/lambda_function.py "$DUMMY_ZIP_FILE"
  exit 1
fi