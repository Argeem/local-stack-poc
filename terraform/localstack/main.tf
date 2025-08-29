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

# variable "sqs_queue_name" {
#     type = string
# }

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
      s3   = var.s3_localstack_endpoint
      sqs  = var.localstack_endpoint
      ecr  = var.localstack_endpoint
      ecs  = var.localstack_endpoint
      iam  = var.localstack_endpoint
      ec2  = var.localstack_endpoint # สำหรับ Security Group (ถ้ามี)
      sts  = var.localstack_endpoint
    }
}

# --- S3: ที่เก็บข้อมูล ---
resource "aws_s3_bucket" "test-bucket" {
  # ตั้งชื่อ S3 bucket ที่จะถูกสร้างขึ้นจริงบน LocalStack
  bucket = var.s3_bucket
}

# --- SQS: คิวข้อความ ---
# resource "aws_sqs_queue" "terraform_queue" {
#   name                      = var.sqs_queue_name
#   delay_seconds             = 90
#   max_message_size          = 2048
#   message_retention_seconds = 86400
#   receive_wait_time_seconds = 10
# }

# --- ECR: ที่เก็บ Docker Image ---
resource "aws_ecr_repository" "app_repo" {
  name = "go-ecs-app-repo"
}

# --- ECS Cluster: บ้านของ Service และ Task ---
resource "aws_ecs_cluster" "app_cluster" {
  name = "go-app-cluster"
}

# --- IAM: สิทธิ์สำหรับให้ ECS ทำงาน ---
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- 6. ECS Task Definition: พิมพ์เขียวของ Container ---
resource "aws_ecs_task_definition" "app_task" {
  family                   = "go-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "go-app-container"
      # ใช้ Image ชั่วคราวก่อน Pipeline จะมาอัปเดตทีหลัง
      image     = "public.ecr.aws/nginx/nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]
    }
  ])
}