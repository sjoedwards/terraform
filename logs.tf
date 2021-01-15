# Define a log group for NGINX
resource "aws_cloudwatch_log_group" "simple_app_log_group" {
  name              = "/ecs/${var.ecs_service_name}-nginx"
  retention_in_days = 30

  tags = {
    Name = "${var.ecs_service_name}-nginx-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "simple_app_log_stream" {
  name           = "${var.ecs_service_name}-nginx-log-stream"
  log_group_name = aws_cloudwatch_log_group.simple_app_log_group.name
}


# Define a log group for app
resource "aws_cloudwatch_log_group" "simple_app_app_log_group" {
  name              = "/ecs/${var.ecs_service_name}-app"
  retention_in_days = 30

  tags = {
    Name = "${var.ecs_service_name}-app-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "simple_app_app_log_stream" {
  name           = "${var.ecs_service_name}-app-log-stream"
  log_group_name = aws_cloudwatch_log_group.simple_app_app_log_group.name
}
