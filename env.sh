export AWS_ACCESS_KEY_ID=dummy
export AWS_SECRET_ACCESS_KEY=dummy
export AWS_REGION=us-east-1
export LOCALSTACK_ENDPOINT="http://localhost:4566"
export S3_LOCALSTACK_ENDPOINT="http://s3.localhost.localstack.cloud:4566"
export S3_BUCKET="my-bucket"
export SQS_QUEUE_NAME="my-sqs-queue"



# Terraform use special env name for use

export TF_VAR_access_key=dummy
export TF_VAR_secret_key=dummy
export TF_VAR_region=us-east-1
export TF_VAR_localstack_endpoint="http://localhost:4566"
export TF_VAR_s3_localstack_endpoint="http://s3.localhost.localstack.cloud:4566"
export TF_VAR_s3_bucket="my-bucket"
export TF_VAR_sqs_queue_name="my-sqs-queue"



