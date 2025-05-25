#!/bin/bash

# Script to test Lambda function deletion permissions

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

echo "Testing Lambda function deletion permissions for function: $TEST_LAMBDA_FUNCTION_NAME"

# Create a dummy zip file for the Lambda code
DUMMY_ZIP_FILE="/tmp/dummy_lambda_code.zip"
echo "def handler(event, context): return {'statusCode': 200, 'body': 'Hello from Lambda!'}" > /tmp/lambda_function.py
zip -j "$DUMMY_ZIP_FILE" /tmp/lambda_function.py > /dev/null

# Attempt to create a dummy Lambda function first, then try to delete it
TEMP_LAMBDA_FUNCTION_NAME="${TEST_LAMBDA_FUNCTION_NAME}-delete-test-$(date +%s)"

echo "Attempting to create temporary Lambda function: $TEMP_LAMBDA_FUNCTION_NAME"
aws lambda create-function \
  --function-name "$TEMP_LAMBDA_FUNCTION_NAME" \
  --runtime "$TEST_LAMBDA_RUNTIME" \
  --role "$TEST_LAMBDA_ROLE_ARN" \
  --handler "$TEST_LAMBDA_HANDLER" \
  --zip-file "fileb://$DUMMY_ZIP_FILE" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -ne 0 ]; then
  echo "WARNING: Could not create temporary Lambda function '$TEMP_LAMBDA_FUNCTION_NAME'. Cannot fully test delete permissions without a function to delete."
  echo "Please ensure you have create permissions for Lambda functions to run this test effectively."
  rm -f /tmp/lambda_function.py "$DUMMY_ZIP_FILE"
  exit 1
fi

echo "Temporary Lambda function '$TEMP_LAMBDA_FUNCTION_NAME' created. Attempting to delete it."
aws lambda delete-function \
  --function-name "$TEMP_LAMBDA_FUNCTION_NAME" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to delete Lambda functions."
  rm -f /tmp/lambda_function.py "$DUMMY_ZIP_FILE"
  exit 0
else
  echo "FAILURE: User does NOT have permissions to delete Lambda functions."
  rm -f /tmp/lambda_function.py "$DUMMY_ZIP_FILE"
  exit 1
fi