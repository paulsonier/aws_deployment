#!/bin/bash

# Script to test RDS database deployment permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$TEST_RDS_DB_NAME" ] || \
   [ -z "$TEST_RDS_MASTER_USERNAME" ] || \
   [ -z "$TEST_RDS_MASTER_PASSWORD" ] || \
   [ -z "$TEST_RDS_DB_INSTANCE_CLASS" ] || \
   [ -z "$TEST_RDS_ALLOCATED_STORAGE" ] || \
   [ -z "$TEST_RDS_ENGINE" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, TEST_RDS_DB_NAME, TEST_RDS_MASTER_USERNAME, TEST_RDS_MASTER_PASSWORD, TEST_RDS_DB_INSTANCE_CLASS, TEST_RDS_ALLOCATED_STORAGE, and TEST_RDS_ENGINE."
  exit 1
fi

echo "Testing RDS database deployment permissions for database: $TEST_RDS_DB_NAME"

# Attempt to create a dummy RDS instance
TEMP_DB_IDENTIFIER="${TEST_RDS_DB_NAME}-test-$(date +%s)"

aws rds create-db-instance \
  --db-name "$TEST_RDS_DB_NAME" \
  --db-instance-identifier "$TEMP_DB_IDENTIFIER" \
  --allocated-storage "$TEST_RDS_ALLOCATED_STORAGE" \
  --db-instance-class "$TEST_RDS_DB_INSTANCE_CLASS" \
  --engine "$TEST_RDS_ENGINE" \
  --master-username "$TEST_RDS_MASTER_USERNAME" \
  --master-user-password "$TEST_RDS_MASTER_PASSWORD" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to deploy RDS databases."
  echo "Cleaning up temporary RDS instance: $TEMP_DB_IDENTIFIER"
  # Wait for the instance to be available before deleting
  aws rds wait db-instance-available --db-instance-identifier "$TEMP_DB_IDENTIFIER" --region "$AWS_DEFAULT_REGION"
  aws rds delete-db-instance \
    --db-instance-identifier "$TEMP_DB_IDENTIFIER" \
    --skip-final-snapshot \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Temporary RDS instance '$TEMP_DB_IDENTIFIER' deletion initiated successfully."
    aws rds wait db-instance-deleted --db-instance-identifier "$TEMP_DB_IDENTIFIER" --region "$AWS_DEFAULT_REGION"
    echo "Temporary RDS instance '$TEMP_DB_IDENTIFIER' deleted successfully."
  else
    echo "WARNING: Failed to initiate deletion of temporary RDS instance '$TEMP_DB_IDENTIFIER'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to deploy RDS databases."
  exit 1
fi