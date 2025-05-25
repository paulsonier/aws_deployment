#!/bin/bash

# Script to deploy an AWS RDS database instance

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$RDS_DB_NAME" ] || \
   [ -z "$RDS_MASTER_USERNAME" ] || \
   [ -z "$RDS_MASTER_PASSWORD" ] || \
   [ -z "$RDS_DB_INSTANCE_CLASS" ] || \
   [ -z "$RDS_ALLOCATED_STORAGE" ] || \
   [ -z "$RDS_ENGINE" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, RDS_DB_NAME, RDS_MASTER_USERNAME, RDS_MASTER_PASSWORD, RDS_DB_INSTANCE_CLASS, RDS_ALLOCATED_STORAGE, and RDS_ENGINE."
  exit 1
fi

echo "Attempting to create RDS database instance: $RDS_DB_NAME"

aws rds create-db-instance \
  --db-name "$RDS_DB_NAME" \
  --db-instance-identifier "$RDS_DB_NAME-instance" \
  --allocated-storage "$RDS_ALLOCATED_STORAGE" \
  --db-instance-class "$RDS_DB_INSTANCE_CLASS" \
  --engine "$RDS_ENGINE" \
  --master-username "$RDS_MASTER_USERNAME" \
  --master-user-password "$RDS_MASTER_PASSWORD" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "RDS database instance '$RDS_DB_NAME-instance' creation initiated successfully."
  echo "You can monitor its status using: aws rds describe-db-instances --db-instance-identifier $RDS_DB_NAME-instance --region $AWS_DEFAULT_REGION"
else
  echo "Failed to initiate RDS database instance creation."
  exit 1
fi