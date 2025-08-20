# Docker Compose file for run local stack

```
docker-compose.yml
```

## Terraform config

```
terraform\localstack\main.tf
```

## Run Terraform

```
terraform init
```

Initialization and preparation step for your project, makes your project "ready to go" before you can start planning or creating any resources.

- Provider Download
- Backend Configuration

```
terraform plan
```

Allows you to see the proposed changes without actually making any modifications to your real infrastructure, helping you catch potential errors early

```
terraform apply
```

Final step where Terraform makes the changes to your infrastructure, bringing it in line with your code.
