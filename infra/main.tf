provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "default" {
  cidr_block = "172.31.0.0/16"

  tags = {
    Environment = var.environment_name
    Name        = "Default VPC"
  }
}

data "aws_subnets" "vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnet" "default_subnet" {
  count = length(data.aws_subnets.vpc_subnets.ids)
  id    = tolist(data.aws_subnets.vpc_subnets.ids)[count.index]
}
