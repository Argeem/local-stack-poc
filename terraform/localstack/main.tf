# Prepare variable for Terraform
variable "access_key"  {
    type = string
}

variable "secret_key"  {
    type = string
}

variable "region"  {
    type = string
}

variable "localstack_endpoint" {
    type = string
}

variable "s3_localstack_endpoint" {
    type = string
}

variable "s3_bucket" {
    type = string
}

variable "sqs_queue_name" {
    type = string
}

provider "aws" {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region

    #  การตั้งค่านี้จะบังคับให้ LocalStack ใช้รูปแบบ URL แบบ path-style 
    s3_use_path_style = true
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true

    # เปลี่ยนปลายทาง (endpoint) การเชื่อมต่อสำหรับบริการ S3, SQS ให้ชี้ไปที่ URL ของ LocalStack
    endpoints {
      s3 = var.s3_localstack_endpoint
      sqs = var.localstack_endpoint
    }
}

# ระกาศว่าจะสร้าง resource ประเภท S3 bucket ของ AWS และตั้งชื่อให้มันในโค้ด Terraform ว่า "test-bucket"
resource "aws_s3_bucket" "test-bucket" {
  # ตั้งชื่อ S3 bucket ที่จะถูกสร้างขึ้นจริงบน LocalStack
  bucket = var.s3_bucket
}

resource "aws_sqs_queue" "terraform_queue" {
  name                      = var.sqs_queue_name
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}