#!/bin/bash

# This script deploys an EC2 instance.
# It depends on the following environment variables:
# AWS_ACCESS_KEY_ID
# AWS_SECRET_ACCESS_KEY
# AWS_DEFAULT_REGION
# EC2_AMI_ID
# EC2_INSTANCE_TYPE
# EC2_KEY_PAIR_NAME

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_DEFAULT_REGION" ] || [ -z "$EC2_AMI_ID" ] || [ -z "$EC2_INSTANCE_TYPE" ] || [ -z "$EC2_KEY_PAIR_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, EC2_AMI_ID, EC2_INSTANCE_TYPE, and EC2_KEY_PAIR_NAME."
  exit 1
fi

echo "Attempting to launch EC2 instance with AMI: $EC2_AMI_ID, instance type: $EC2_INSTANCE_TYPE, and key pair: $EC2_KEY_PAIR_NAME in region: $AWS_DEFAULT_REGION"

aws ec2 run-instances \
  --image-id "$EC2_AMI_ID" \
  --count 1 \
  --instance-type "$EC2_INSTANCE_TYPE" \
  --key-name "$EC2_KEY_PAIR_NAME" \
  --region "$AWS_DEFAULT_REGION"

if [ $? -eq 0 ]; then
  echo "EC2 instance launch command executed successfully. Check AWS console for instance status."
else
  echo "Error launching EC2 instance."
  exit 1
fi