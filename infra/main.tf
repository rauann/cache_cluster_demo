provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Environment = var.environment_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat_ip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default.id
}

resource "aws_nat_gateway" "ngw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat_ip.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}
