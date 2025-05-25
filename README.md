# AWS Deployment Scripts

This repository contains bash scripts to deploy AWS resources from the command line. These scripts are designed to be run in an environment where necessary AWS credentials and configuration are provided via environment variables.

## Scripts

### `deploy_s3.sh`

This script deploys an S3 bucket.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region where the S3 bucket will be created (e.g., `us-east-1`).
- `S3_BUCKET_NAME`: The desired name for your S3 bucket.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export S3_BUCKET_NAME="my-unique-s3-bucket-name"
./deploy_s3.sh
```

### `deploy_ec2.sh`

This script deploys an EC2 instance.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region where the EC2 instance will be launched (e.g., `us-east-1`).
- `EC2_AMI_ID`: The Amazon Machine Image (AMI) ID to use for the instance (e.g., `ami-0abcdef1234567890`).
- `EC2_INSTANCE_TYPE`: The instance type (e.g., `t2.micro`).
- `EC2_KEY_PAIR_NAME`: The name of an existing EC2 key pair to associate with the instance.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export EC2_AMI_ID="ami-0abcdef1234567890" # Replace with a valid AMI ID for your region
export EC2_INSTANCE_TYPE="t2.micro"
export EC2_KEY_PAIR_NAME="my-ec2-key-pair" # Replace with your key pair name
./deploy_ec2.sh
```

## Before Running

Ensure you have the AWS CLI installed and configured. Although these scripts rely on environment variables, having the AWS CLI configured with default credentials can help with initial setup and troubleshooting.

```bash
pip install awscli
aws configure
```

**Note:** For production environments, consider using AWS IAM roles and instance profiles instead of directly setting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables for enhanced security.