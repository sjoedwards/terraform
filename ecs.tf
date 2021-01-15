resource "aws_ecs_cluster" "main" {
  name = "${var.ecs_service_name}-cluster"
}

resource "aws_ecs_task_definition" "nginx" {
  family                   = "${var.ecs_service_name}-nginx-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Needs both as has app and nginx pod
  cpu    = var.nginx_fargate_cpu + var.app_fargate_cpu
  memory = var.nginx_fargate_memory + var.app_fargate_memory
  //JSONEncode allows us to use JSON inside of our definition
  container_definitions = jsonencode(
    [
      {
        name        = "nginx"
        image       = data.aws_ecr_repository.ecr_repo_nginx.repository_url
        cpu         = var.nginx_fargate_cpu
        memory      = var.nginx_fargate_memory
        networkMode = "awsvpc"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${var.ecs_service_name}-nginx"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
        portMappings = [
          {
            containerPort = var.nginx_port
            hostPort      = var.nginx_port
          }
        ]
      },
      {
        # Can refer internally to the app by the name
        name   = "app"
        image  = data.aws_ecr_repository.ecr_repo_app.repository_url
        cpu    = var.app_fargate_cpu
        memory = var.app_fargate_memory
        # Using Fargate means we must use awsvpc
        networkMode = "awsvpc"
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${var.ecs_service_name}-app"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
        portMappings = [
          {
            containerPort = var.app_port
            hostPort      = var.app_port
          }
        ]
      }
    ]
  )
}

# The service - this instanciates the tasks
# Therefore it includes a connection to the ECS cluster to launch
resource "aws_ecs_service" "nginx" {
  name            = "${var.ecs_service_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.nginx.arn
  desired_count   = var.nginx_count
  launch_type     = "FARGATE"

  # Declares the nginx security group - which requires connection from resources with the load balancer group
  network_configuration {
    security_groups  = [aws_security_group.nginx_task.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.nginx.id
    container_name   = "nginx"
    container_port   = var.nginx_port
  }

  # Must be running in order for the service to start
  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}
