# ALB Security Group: Edit to restrict access to the application
# Controls access to the load balancer - can only access on the nginx port
resource "aws_security_group" "lb" {
  name        = "${var.ecs_service_name}-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = "tcp"
    from_port = var.nginx_port
    to_port   = var.nginx_port
    # Traffic from any IP!
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group from NGINX task
resource "aws_security_group" "nginx_task" {
  name        = "${var.ecs_service_name}-nginx-task-security-group"
  description = "allow inbound access to the NGINX task from the ALB only"
  vpc_id      = aws_vpc.main.id

  # Allow ingress to the nginx_port - but only from the load balancer!
  ingress {
    protocol        = "tcp"
    from_port       = var.nginx_port
    to_port         = var.nginx_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for the App task
resource "aws_security_group" "app_task" {
  name        = "${var.ecs_service_name}-app-task-security-group"
  description = "allow inbound access to the Application task from the ALB only"
  vpc_id      = aws_vpc.main.id


  # Allow ingress to the app_port - but only from resources assigned to the load balancer security group!
  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
