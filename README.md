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

### `deploy_rds.sh`

This script deploys an AWS RDS database instance.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to deploy resources (e.g., `us-east-1`).
- `RDS_DB_NAME`: The name for the database (e.g., `mydb`).
- `RDS_MASTER_USERNAME`: The master username for the database.
- `RDS_MASTER_PASSWORD`: The master password for the database.
- `RDS_DB_INSTANCE_CLASS`: The DB instance class (e.g., `db.t2.micro`).
- `RDS_ALLOCATED_STORAGE`: The allocated storage in GiB (e.g., `20`).
- `RDS_ENGINE`: The database engine (e.g., `mysql`, `postgres`).

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export RDS_DB_NAME="my-rds-db"
export RDS_MASTER_USERNAME="admin"
export RDS_MASTER_PASSWORD="your_master_password"
export RDS_DB_INSTANCE_CLASS="db.t2.micro"
export RDS_ALLOCATED_STORAGE="20"
export RDS_ENGINE="mysql" # or postgres, etc.
./deploy_rds.sh
```

### `deploy_lambda.sh`

This script deploys an AWS Lambda function. It can create a new function or update an existing one.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to deploy the Lambda function (e.g., `us-east-1`).
- `LAMBDA_FUNCTION_NAME`: The name for your Lambda function.
- `LAMBDA_RUNTIME`: The runtime for the Lambda function (e.g., `nodejs18.x`, `python3.9`).
- `LAMBDA_HANDLER`: The handler for the Lambda function (e.g., `index.handler`).
- `LAMBDA_S3_BUCKET`: The S3 bucket where your Lambda deployment package (zip file) is stored.
- `LAMBDA_S3_KEY`: The S3 key (path to the zip file) of your Lambda deployment package.
- `LAMBDA_ROLE_ARN`: The ARN of the IAM role that Lambda will assume to execute your function.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export LAMBDA_FUNCTION_NAME="my-lambda-function"
export LAMBDA_RUNTIME="python3.9"
export LAMBDA_HANDLER="main.handler"
export LAMBDA_S3_BUCKET="my-lambda-code-bucket"
export LAMBDA_S3_KEY="my-lambda-function.zip"
export LAMBDA_ROLE_ARN="arn:aws:iam::123456789012:role/lambda-exection-role" # Replace with your Lambda execution role ARN
./deploy_lambda.sh
```

## Permission Verification Scripts

This directory (`verify_permissions/`) contains scripts to test a user's AWS permissions for deploying, modifying, and deleting various resources. These scripts attempt to perform the respective actions and report success or failure.

**Important Notes:**
- These scripts require specific environment variables to be set, as detailed below.
- For modification and deletion tests, some scripts might attempt to create a temporary resource if one doesn't exist, or require an existing resource to modify/delete.
- Always review the script content before execution to understand the actions it will perform in your AWS account.
- Ensure you have appropriate cleanup mechanisms in place for any temporary resources created by these tests.

### `verify_permissions/test_deploy_s3.sh`

Tests permissions to create an S3 bucket. It creates a temporary bucket and then attempts to delete it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test (e.g., `us-east-1`).
- `TEST_S3_BUCKET_NAME`: A base name for the temporary S3 bucket to be created. A unique suffix will be added.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_S3_BUCKET_NAME="my-test-s3-bucket"
./verify_permissions/test_deploy_s3.sh
```

### `verify_permissions/test_modify_s3.sh`

Tests permissions to modify an S3 bucket. It attempts to put a dummy bucket policy on an existing bucket and then removes it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `EXISTING_S3_BUCKET_NAME`: The name of an existing S3 bucket to test modification on.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export EXISTING_S3_BUCKET_NAME="your-existing-s3-bucket"
./verify_permissions/test_modify_s3.sh
```

### `verify_permissions/test_delete_s3.sh`

Tests permissions to delete an S3 bucket. It creates a temporary bucket and then attempts to delete it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_S3_BUCKET_NAME`: A base name for the temporary S3 bucket to be created and deleted.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_S3_BUCKET_NAME="my-test-s3-bucket-for-deletion"
./verify_permissions/test_delete_s3.sh
```

### `verify_permissions/test_deploy_rds.sh`

Tests permissions to create an RDS database instance. It creates a temporary RDS instance and then attempts to delete it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_RDS_DB_NAME`: The name for the temporary database.
- `TEST_RDS_MASTER_USERNAME`: Master username for the temporary database.
- `TEST_RDS_MASTER_PASSWORD`: Master password for the temporary database.
- `TEST_RDS_DB_INSTANCE_CLASS`: DB instance class (e.g., `db.t3.micro`).
- `TEST_RDS_ALLOCATED_STORAGE`: Allocated storage in GiB (e.g., `20`).
- `TEST_RDS_ENGINE`: Database engine (e.g., `mysql`, `postgres`).

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_RDS_DB_NAME="testdb"
export TEST_RDS_MASTER_USERNAME="admin"
export TEST_RDS_MASTER_PASSWORD="password"
export TEST_RDS_DB_INSTANCE_CLASS="db.t3.micro"
export TEST_RDS_ALLOCATED_STORAGE="20"
export TEST_RDS_ENGINE="mysql"
./verify_permissions/test_deploy_rds.sh
```

### `verify_permissions/test_modify_rds.sh`

Tests permissions to modify an RDS database instance. It attempts to change the allocated storage of an existing instance and then reverts it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `EXISTING_RDS_DB_IDENTIFIER`: The identifier of an existing RDS instance to test modification on.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export EXISTING_RDS_DB_IDENTIFIER="your-existing-rds-instance"
./verify_permissions/test_modify_rds.sh
```

### `verify_permissions/test_delete_rds.sh`

Tests permissions to delete an RDS database instance. It creates a temporary RDS instance and then attempts to delete it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_RDS_DB_NAME`: The name for the temporary database.
- `TEST_RDS_MASTER_USERNAME`: Master username for the temporary database.
- `TEST_RDS_MASTER_PASSWORD`: Master password for the temporary database.
- `TEST_RDS_DB_INSTANCE_CLASS`: DB instance class (e.g., `db.t3.micro`).
- `TEST_RDS_ALLOCATED_STORAGE`: Allocated storage in GiB (e.g., `20`).
- `TEST_RDS_ENGINE`: Database engine (e.g., `mysql`, `postgres`).

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_RDS_DB_NAME="testdb-for-deletion"
export TEST_RDS_MASTER_USERNAME="admin"
export TEST_RDS_MASTER_PASSWORD="password"
export TEST_RDS_DB_INSTANCE_CLASS="db.t3.micro"
export TEST_RDS_ALLOCATED_STORAGE="20"
export TEST_RDS_ENGINE="mysql"
./verify_permissions/test_delete_rds.sh
```

### `verify_permissions/test_deploy_ec2.sh`

Tests permissions to launch an EC2 instance. It launches a temporary EC2 instance and then terminates it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_EC2_AMI_ID`: An AMI ID to use for the test instance (e.g., a public Amazon Linux 2 AMI).
- `TEST_EC2_INSTANCE_TYPE`: The instance type (e.g., `t2.micro`).
- `TEST_EC2_KEY_PAIR_NAME`: The name of an existing EC2 key pair in your account.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_EC2_AMI_ID="ami-0abcdef1234567890" # Replace with a valid AMI ID for your region
export TEST_EC2_INSTANCE_TYPE="t2.micro"
export TEST_EC2_KEY_PAIR_NAME="my-ec2-keypair" # Replace with an existing key pair name
./verify_permissions/test_deploy_ec2.sh
```

### `verify_permissions/test_modify_ec2.sh`

Tests permissions to modify an EC2 instance. It attempts to add a tag to an existing instance and then removes it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `EXISTING_EC2_INSTANCE_ID`: The ID of an existing EC2 instance to test modification on.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export EXISTING_EC2_INSTANCE_ID="i-0abcdef1234567890" # Replace with an existing EC2 instance ID
./verify_permissions/test_modify_ec2.sh
```

### `verify_permissions/test_delete_ec2.sh`

Tests permissions to terminate an EC2 instance. It launches a temporary EC2 instance and then terminates it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_EC2_AMI_ID`: An AMI ID to use for the test instance.
- `TEST_EC2_INSTANCE_TYPE`: The instance type.
- `TEST_EC2_KEY_PAIR_NAME`: The name of an existing EC2 key pair.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_EC2_AMI_ID="ami-0abcdef1234567890" # Replace with a valid AMI ID for your region
export TEST_EC2_INSTANCE_TYPE="t2.micro"
export TEST_EC2_KEY_PAIR_NAME="my-ec2-keypair" # Replace with an existing key pair name
./verify_permissions/test_delete_ec2.sh
```

### `verify_permissions/test_deploy_lambda.sh`

Tests permissions to create a Lambda function. It creates a temporary Lambda function and then deletes it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_LAMBDA_FUNCTION_NAME`: A base name for the temporary Lambda function.
- `TEST_LAMBDA_RUNTIME`: The runtime for the Lambda function (e.g., `python3.9`).
- `TEST_LAMBDA_HANDLER`: The handler for the Lambda function (e.g., `lambda_function.handler`).
- `TEST_LAMBDA_ROLE_ARN`: The ARN of an IAM role that Lambda can assume (must have `lambda:CreateFunction` and `lambda:DeleteFunction` permissions, and trust policy allowing Lambda to assume it).

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_LAMBDA_FUNCTION_NAME="my-test-lambda-function"
export TEST_LAMBDA_RUNTIME="python3.9"
export TEST_LAMBDA_HANDLER="lambda_function.handler"
export TEST_LAMBDA_ROLE_ARN="arn:aws:iam::123456789012:role/lambda-test-role" # Replace with a valid Lambda execution role ARN
./verify_permissions/test_deploy_lambda.sh
```

### `verify_permissions/test_modify_lambda.sh`

Tests permissions to modify a Lambda function. It attempts to update the role of an existing Lambda function and then reverts it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `EXISTING_LAMBDA_FUNCTION_NAME`: The name of an existing Lambda function to test modification on.
- `TEST_LAMBDA_ROLE_ARN`: A *different* IAM role ARN that Lambda can assume, used for testing the modification. The user running the script must have permissions to update the function's configuration to this role, and then revert it.

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export EXISTING_LAMBDA_FUNCTION_NAME="your-existing-lambda-function"
export TEST_LAMBDA_ROLE_ARN="arn:aws:iam::123456789012:role/another-lambda-role" # Replace with a different valid Lambda execution role ARN
./verify_permissions/test_modify_lambda.sh
```

### `verify_permissions/test_delete_lambda.sh`

Tests permissions to delete a Lambda function. It creates a temporary Lambda function and then deletes it.

**Required Environment Variables:**
- `AWS_ACCESS_KEY_ID`: Your AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key.
- `AWS_DEFAULT_REGION`: The AWS region to perform the test.
- `TEST_LAMBDA_FUNCTION_NAME`: A base name for the temporary Lambda function.
- `TEST_LAMBDA_RUNTIME`: The runtime for the Lambda function.
- `TEST_LAMBDA_HANDLER`: The handler for the Lambda function.
- `TEST_LAMBDA_ROLE_ARN`: The ARN of an IAM role that Lambda can assume (must have `lambda:CreateFunction` and `lambda:DeleteFunction` permissions, and trust policy allowing Lambda to assume it).

**Usage:**
```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"
export TEST_LAMBDA_FUNCTION_NAME="my-test-lambda-function-for-deletion"
export TEST_LAMBDA_RUNTIME="python3.9"
export TEST_LAMBDA_HANDLER="lambda_function.handler"
export TEST_LAMBDA_ROLE_ARN="arn:aws:iam::123456789012:role/lambda-test-role" # Replace with a valid Lambda execution role ARN
./verify_permissions/test_delete_lambda.sh
```

## Before Running

Ensure you have the AWS CLI installed and configured. Although these scripts rely on environment variables, having the AWS CLI configured with default credentials can help with initial setup and troubleshooting.

```bash
pip install awscli
aws configure
```

**Note:** For production environments, consider using AWS IAM roles and instance profiles instead of directly setting `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables for enhanced security.