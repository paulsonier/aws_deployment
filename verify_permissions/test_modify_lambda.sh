#!/bin/bash

# Script to test Lambda function modification permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$EXISTING_LAMBDA_FUNCTION_NAME" ] || \
   [ -z "$TEST_LAMBDA_ROLE_ARN" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, EXISTING_LAMBDA_FUNCTION_NAME, and TEST_LAMBDA_ROLE_ARN."
  exit 1
fi

echo "Testing Lambda function modification permissions for function: $EXISTING_LAMBDA_FUNCTION_NAME"

# Attempt to update the function's description or role to test modify permissions
# First, get the current role ARN to revert after the test
CURRENT_ROLE_ARN=$(aws lambda get-function-configuration \
  --function-name "$EXISTING_LAMBDA_FUNCTION_NAME" \
  --query "Role" \
  --output text \
  --region "$AWS_DEFAULT_REGION" 2>/dev/null)

if [ -z "$CURRENT_ROLE_ARN" ]; then
  echo "Error: Could not retrieve current role ARN for '$EXISTING_LAMBDA_FUNCTION_NAME'. Ensure the function exists and you have get-function-configuration permissions."
  exit 1
fi

echo "Attempting to update the role of '$EXISTING_LAMBDA_FUNCTION_NAME' to a dummy role ARN."

aws lambda update-function-configuration \
  --function-name "$EXISTING_LAMBDA_FUNCTION_NAME" \
  --role "$TEST_LAMBDA_ROLE_ARN" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to modify Lambda functions."
  echo "Attempting to revert the role of '$EXISTING_LAMBDA_FUNCTION_NAME' back to its original role."
  aws lambda update-function-configuration \
    --function-name "$EXISTING_LAMBDA_FUNCTION_NAME" \
    --role "$CURRENT_ROLE_ARN" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Lambda function role reverted successfully."
  else
    echo "WARNING: Failed to revert Lambda function role for '$EXISTING_LAMBDA_FUNCTION_NAME'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to modify Lambda functions."
  exit 1
fi