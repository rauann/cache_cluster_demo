resource "aws_lb" "cache_cluster_demo" {
  name               = "${var.environment_name}-${var.name}"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnet.default_subnet.*.id
  security_groups    = [aws_security_group.lb_security_group.id]

  tags = {
    Environment = var.environment_name
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  port        = "4000"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default.id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/healthcheck"
    matcher             = "200"
    interval            = 30
    unhealthy_threshold = 10
    timeout             = 25
  }

  tags = {
    Environment = var.environment_name
  }

  depends_on = [aws_lb.cache_cluster_demo]
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.cache_cluster_demo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    type             = "forward"
  }
}
