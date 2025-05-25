#!/bin/bash

# Script to test RDS database modification permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$EXISTING_RDS_DB_IDENTIFIER" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and EXISTING_RDS_DB_IDENTIFIER."
  exit 1
fi

echo "Testing RDS database modification permissions for instance: $EXISTING_RDS_DB_IDENTIFIER"

# Get current allocated storage to revert after test
CURRENT_ALLOCATED_STORAGE=$(aws rds describe-db-instances \
  --db-instance-identifier "$EXISTING_RDS_DB_IDENTIFIER" \
  --query "DBInstances[0].AllocatedStorage" \
  --output text \
  --region "$AWS_DEFAULT_REGION" 2>/dev/null)

if [ -z "$CURRENT_ALLOCATED_STORAGE" ]; then
  echo "Error: Could not retrieve current allocated storage for '$EXISTING_RDS_DB_IDENTIFIER'. Ensure the instance exists and you have describe permissions."
  exit 1
fi

# Attempt to modify the allocated storage (e.g., increase by 1 GiB)
NEW_ALLOCATED_STORAGE=$((CURRENT_ALLOCATED_STORAGE + 1))

echo "Attempting to modify allocated storage of '$EXISTING_RDS_DB_IDENTIFIER' from ${CURRENT_ALLOCATED_STORAGE} to ${NEW_ALLOCATED_STORAGE} GiB."

aws rds modify-db-instance \
  --db-instance-identifier "$EXISTING_RDS_DB_IDENTIFIER" \
  --allocated-storage "$NEW_ALLOCATED_STORAGE" \
  --apply-immediately \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to modify RDS databases."
  echo "Attempting to revert allocated storage of '$EXISTING_RDS_DB_IDENTIFIER' back to ${CURRENT_ALLOCATED_STORAGE} GiB."
  # Wait for the modification to complete before reverting
  aws rds wait db-instance-available --db-instance-identifier "$EXISTING_RDS_DB_IDENTIFIER" --region "$AWS_DEFAULT_REGION"
  aws rds modify-db-instance \
    --db-instance-identifier "$EXISTING_RDS_DB_IDENTIFIER" \
    --allocated-storage "$CURRENT_ALLOCATED_STORAGE" \
    --apply-immediately \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Allocated storage reverted successfully."
  else
    echo "WARNING: Failed to revert allocated storage for '$EXISTING_RDS_DB_IDENTIFIER'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to modify RDS databases."
  exit 1
fi