#!/bin/bash

# Script to test EC2 instance deletion permissions

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

echo "Testing EC2 instance deletion permissions."

# Attempt to run a dummy EC2 instance first, then try to terminate it
INSTANCE_ID=""
RUN_INSTANCES_OUTPUT=$(aws ec2 run-instances \
  --image-id "$TEST_EC2_AMI_ID" \
  --count 1 \
  --instance-type "$TEST_EC2_INSTANCE_TYPE" \
  --key-name "$TEST_EC2_KEY_PAIR_NAME" \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=temp-delete-test-instance}]' \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager 2>&1)

if [ $? -ne 0 ]; then
  echo "WARNING: Could not create temporary EC2 instance. Cannot fully test delete permissions without an instance to delete."
  echo "Error details: $RUN_INSTANCES_OUTPUT"
  echo "Please ensure you have create permissions for EC2 instances to run this test effectively."
  exit 1
fi

INSTANCE_ID=$(echo "$RUN_INSTANCES_OUTPUT" | grep -oP '"InstanceId": "\K[^"]+')
echo "Temporary EC2 instance '$INSTANCE_ID' created. Waiting for it to be running before attempting termination."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$AWS_DEFAULT_REGION"

echo "Attempting to terminate temporary EC2 instance: $INSTANCE_ID"
aws ec2 terminate-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to delete EC2 instances."
  echo "Waiting for temporary EC2 instance '$INSTANCE_ID' to be terminated."
  aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID" --region "$AWS_DEFAULT_REGION"
  echo "Temporary EC2 instance '$INSTANCE_ID' terminated successfully."
  exit 0
else
  echo "FAILURE: User does NOT have permissions to delete EC2 instances."
  exit 1
fi