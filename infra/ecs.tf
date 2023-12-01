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

resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = "${var.environment_name}-${var.name}.local"
  description = "ECS Service Discovery namespace for ${var.environment_name}-${var.name}"
  vpc         = aws_vpc.default.id
}

resource "aws_service_discovery_service" "service_discovery" {
  name = "${var.environment_name}-${var.name}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
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
      {"name": "SECRET_KEY_BASE", "value": "9fDANWSr61sEAqZ7EFWa7STYdy7TUdfZX5lgHpf98XgKrgYk1L69YdecijarZCSS"}
    ],
    "essential": true,
    "image": "${aws_ecr_repository.cache_cluster_demo_repo.repository_url}:latest",
    "name": "${var.environment_name}-${var.name}",
    "portMappings": [
        {
            "containerPort": 4000,
            "hostPort": 4000,
            "protocol": "tcp"
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

  # This will create a service registry and register our services ip address when it starts up.
  # It uses Route53 to do this by creating a private DNS entry that can be called anything you like.
  # In the `aws_service_discovery_private_dns_namespace` definition, we called it `ecs_app.local`.
  # When a new task starts up, it will be registered as an `A` record under that DNS namespace.
  service_registries {
    registry_arn   = aws_service_discovery_service.service_discovery.arn
    container_name = "${var.environment_name}-${var.name}"
  }

  depends_on = [
    aws_lb_listener.cache_cluster_demo_http,
    aws_ecs_task_definition.cache_cluster_demo
  ]
}
