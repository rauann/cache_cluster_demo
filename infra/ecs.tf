# Role for ECS task
# This is because our Fargate ECS must be able to pull images from ECS
# and put logs from application container to log driver

data "aws_iam_policy_document" "ecs_task_exec_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.environment_name}-${var.name}-taskrole-ecs"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_role" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Cloudwatch logs

resource "aws_cloudwatch_log_group" "cache_cluster_demo" {
  name = "/fargate/${var.environment_name}-${var.name}"
}

# Cluster

resource "aws_ecs_cluster" "default" {
  depends_on = [aws_cloudwatch_log_group.cache_cluster_demo]
  name       = "${var.environment_name}-${var.name}"
}

resource "aws_ssm_parameter" "release_cookie" {
  name  = "${var.environment_name}-${var.name}-release_cookie"
  type  = "String"
  value = "sTlajn_v7LJTGEHmoHftcrYLAgKQhTjpKN28QDFdFNhfAj02NPISgQ=="
}

# Task definition for the application

resource "aws_ecs_task_definition" "cache_cluster_demo" {
  family                   = "${var.environment_name}-${var.name}-td"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_application_cpu
  memory                   = var.ecs_fargate_application_mem
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  container_definitions    = <<TASK_DEFINITION
[
  {
    "environment": [
      {"name": "SECRET_KEY_BASE", "value": "9fDANWSr61sEAqZ7EFWa7STYdy7TUdfZX5lgHpf98XgKrgYk1L69YdecijarZCSS"},
      {"name": "RELEASE_COOKIE", "value": "${aws_ssm_parameter.release_cookie.value}"}
    ],
    "image": "${aws_ecr_repository.cache_cluster_demo_repo.repository_url}:latest",
    "name": "${var.environment_name}-${var.name}",
    "portMappings": [
        {
            "containerPort": 4000
        }
      ],
    "linuxParameters": {
      "initProcessEnabled": true
    },
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.cache_cluster_demo.name}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs-fargate"
      }
    }
  }
]
TASK_DEFINITION
}


resource "aws_ecs_service" "cache_cluster_demo" {
  name                   = "${var.environment_name}-${var.name}-service"
  cluster                = aws_ecs_cluster.default.id
  launch_type            = "FARGATE"
  task_definition        = aws_ecs_task_definition.cache_cluster_demo.arn
  desired_count          = var.ecs_application_count
  enable_execute_command = true

  load_balancer {
    target_group_arn = aws_lb_target_group.cache_cluster_demo.arn
    container_name   = "${var.environment_name}-${var.name}"
    container_port   = 4000
  }

  network_configuration {
    assign_public_ip = false

    security_groups = [
      aws_security_group.egress-all.id,
      aws_security_group.cache_cluster_demo_service.id
    ]
    subnets = [aws_subnet.private.id]
  }

  depends_on = [
    aws_lb_listener.cache_cluster_demo_http,
    aws_ecs_task_definition.cache_cluster_demo
  ]
}
