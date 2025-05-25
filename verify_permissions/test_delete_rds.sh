#!/bin/bash

# Script to test RDS database deletion permissions

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

echo "Testing RDS database deletion permissions for database: $TEST_RDS_DB_NAME"

# Attempt to create a dummy RDS instance first, then try to delete it
TEMP_DB_IDENTIFIER="${TEST_RDS_DB_NAME}-delete-test-$(date +%s)"

echo "Attempting to create temporary RDS instance: $TEMP_DB_IDENTIFIER"
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

if [ $? -ne 0 ]; then
  echo "WARNING: Could not create temporary RDS instance '$TEMP_DB_IDENTIFIER'. Cannot fully test delete permissions without an instance to delete."
  echo "Please ensure you have create permissions for RDS databases to run this test effectively."
  exit 1
fi

echo "Temporary RDS instance '$TEMP_DB_IDENTIFIER' created. Waiting for it to be available before attempting deletion."
aws rds wait db-instance-available --db-instance-identifier "$TEMP_DB_IDENTIFIER" --region "$AWS_DEFAULT_REGION"

echo "Attempting to delete temporary RDS instance: $TEMP_DB_IDENTIFIER"
aws rds delete-db-instance \
  --db-instance-identifier "$TEMP_DB_IDENTIFIER" \
  --skip-final-snapshot \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to delete RDS databases."
  echo "Waiting for temporary RDS instance '$TEMP_DB_IDENTIFIER' to be deleted."
  aws rds wait db-instance-deleted --db-instance-identifier "$TEMP_DB_IDENTIFIER" --region "$AWS_DEFAULT_REGION"
  echo "Temporary RDS instance '$TEMP_DB_IDENTIFIER' deleted successfully."
  exit 0
else
  echo "FAILURE: User does NOT have permissions to delete RDS databases."
  exit 1
fi