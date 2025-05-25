#!/bin/bash

# Script to test EC2 instance deployment permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$TEST_EC2_AMI_ID" ] || \
   [ -z "$TEST_EC2_INSTANCE_TYPE" ] || \
   [ -z "$TEST_EC2_KEY_PAIR_NAME" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, TEST_EC2_AMI_ID, TEST_EC2_INSTANCE_TYPE, and TEST_EC2_KEY_PAIR_NAME."
  exit 1
fi

echo "Testing EC2 instance deployment permissions with AMI: $TEST_EC2_AMI_ID, Instance Type: $TEST_EC2_INSTANCE_TYPE"

# Attempt to run a dummy EC2 instance
INSTANCE_ID=""
RUN_INSTANCES_OUTPUT=$(aws ec2 run-instances \
  --image-id "$TEST_EC2_AMI_ID" \
  --count 1 \
  --instance-type "$TEST_EC2_INSTANCE_TYPE" \
  --key-name "$TEST_EC2_KEY_PAIR_NAME" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=temp-test-instance}]' \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager 2>&1)

if [ $? -eq 0 ]; then
  INSTANCE_ID=$(echo "$RUN_INSTANCES_OUTPUT" | grep -oP '"InstanceId": "\K[^"]+')
  echo "SUCCESS: User has permissions to deploy EC2 instances. Instance ID: $INSTANCE_ID"
  echo "Cleaning up temporary EC2 instance: $INSTANCE_ID"
  # Terminate the instance
  aws ec2 terminate-instances \
    --instance-ids "$INSTANCE_ID" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Temporary EC2 instance '$INSTANCE_ID' termination initiated successfully."
    aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$AWS_DEFAULT_REGION"
    echo "Temporary EC2 instance '$INSTANCE_ID' terminated successfully."
  else
    echo "WARNING: Failed to initiate termination of temporary EC2 instance '$INSTANCE_ID'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to deploy EC2 instances."
  echo "Error details: $RUN_INSTANCES_OUTPUT"
  exit 1
fi