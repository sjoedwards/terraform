variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "eu-west-2"
}

variable "ecs_service_name" {
  default = "simple-app"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = 2
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role Name"
  default     = "myEcsAutoScaleRole"
}

variable "nginx_port" {
  description = "Port exposed by the NGINX docker image"
  default     = 80
}

variable "app_port" {
  description = "Port exposed by the app docker image"
  default     = 3000
}

variable "nginx_count" {
  description = "Number of NGINX containers to run"
  default     = 2
}

variable "nginx_fargate_cpu" {
  description = "Fargate instance CPU units to provision for NGINX (1 vCPU = 1024 CPU units)"
  default     = 256
}

variable "nginx_fargate_memory" {
  description = "Fargate instance memory to provision for NGINX (in MiB)"
  default     = 512
}

variable "app_count" {
  description = "Number of back-end application containers to run"
  default     = 2
}

variable "app_fargate_cpu" {
  description = "Fargate instance CPU units to provision for back-end application (1 vCPU = 1024 CPU units)"
  default     = 256
}

variable "app_fargate_memory" {
  description = "Fargate instance memory to provision for back-end application (in MiB)"
  default     = 512
}
