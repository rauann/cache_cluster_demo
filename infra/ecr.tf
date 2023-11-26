resource "aws_ecr_repository" "cache_cluster_demo_repo" {
  name                 = "${var.environment_name}-${var.name}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
