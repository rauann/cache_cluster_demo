resource "aws_lb" "cache_cluster_demo" {
  name = "${var.environment_name}-${var.name}"

  subnets = [
    aws_subnet.public.id,
    aws_subnet.private.id
  ]

  security_groups = [
    aws_security_group.http.id,
    aws_security_group.https.id,
    aws_security_group.egress-all.id
  ]

  tags = {
    Environment = var.environment_name
  }
}

resource "aws_lb_target_group" "cache_cluster_demo" {
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

resource "aws_lb_listener" "cache_cluster_demo_http" {
  load_balancer_arn = aws_lb.cache_cluster_demo.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.cache_cluster_demo.arn
    type             = "forward"
  }
}
