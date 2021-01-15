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
