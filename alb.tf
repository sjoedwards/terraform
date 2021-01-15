# Defines the load balancer itself!
resource "aws_alb" "main" {
  name = "${var.ecs_service_name}-load-balancer"
  # Selects 'all of the public subnets'
  subnets = aws_subnet.public.*.id
  # Bind to the load balancer security group - can send traffic to the two security groups
  security_groups = [aws_security_group.lb.id]
}

# Traffic is forwarded to the target group on the nginx port by the load balancer listener
resource "aws_alb_target_group" "nginx" {
  name        = "${var.ecs_service_name}-target-group"
  port        = var.nginx_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Forward all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = var.nginx_port
  protocol          = "HTTP"

  default_action {
    # ARN is Amazon Resource Number
    target_group_arn = aws_alb_target_group.nginx.id
    type             = "forward"
  }
}
