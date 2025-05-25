#!/bin/bash

# Script to test EC2 instance modification permissions

# Check for required environment variables
if [ -z "$AWS_ACCESS_KEY_ID" ] || \
   [ -z "$AWS_SECRET_ACCESS_KEY" ] || \
   [ -z "$AWS_DEFAULT_REGION" ] || \
   [ -z "$EXISTING_EC2_INSTANCE_ID" ]; then
  echo "Error: One or more required environment variables are not set."
  echo "Please set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION, and EXISTING_EC2_INSTANCE_ID."
  exit 1
fi

echo "Testing EC2 instance modification permissions for instance: $EXISTING_EC2_INSTANCE_ID"

# Attempt to modify an attribute (e.g., instance type to a compatible one, then revert)
# This is a more complex test as it requires knowing the current state and a valid modification.
# For simplicity, we'll try to add/remove a tag, which is a common modification.

TAG_KEY="PermissionTest"
TAG_VALUE="Modified"

echo "Attempting to add tag '$TAG_KEY=$TAG_VALUE' to instance '$EXISTING_EC2_INSTANCE_ID'."

aws ec2 create-tags \
  --resources "$EXISTING_EC2_INSTANCE_ID" \
  --tags Key="$TAG_KEY",Value="$TAG_VALUE" \
  --region "$AWS_DEFAULT_REGION" \
  --no-cli-pager

if [ $? -eq 0 ]; then
  echo "SUCCESS: User has permissions to modify EC2 instances (e.g., create tags)."
  echo "Attempting to remove tag '$TAG_KEY' from instance '$EXISTING_EC2_INSTANCE_ID'."
  aws ec2 delete-tags \
    --resources "$EXISTING_EC2_INSTANCE_ID" \
    --tags Key="$TAG_KEY" \
    --region "$AWS_DEFAULT_REGION" \
    --no-cli-pager
  if [ $? -eq 0 ]; then
    echo "Tag '$TAG_KEY' removed successfully."
  else
    echo "WARNING: Failed to remove tag '$TAG_KEY' from instance '$EXISTING_EC2_INSTANCE_ID'. Manual cleanup may be required."
  fi
  exit 0
else
  echo "FAILURE: User does NOT have permissions to modify EC2 instances."
  exit 1
fi