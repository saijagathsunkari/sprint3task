provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired VPC CIDR block
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"  # Replace with your desired subnet CIDR block
  availability_zone = "us-east-1a"   # Replace with your desired availability zone in the region
}

resource "aws_comprehend_endpoint" "private_endpoint" {
  name = "comprehend-private-endpoint"
  subnet_ids = [aws_subnet.main.id]

  security_group_ids = []  # You can specify security group IDs if needed

  # Set this to true to enable DNS resolution for the endpoint
  enable_dns_support = true

  # Set this to true to enable private DNS name resolution for the endpoint
  enable_private_dns = true

  service_name = "comprehend.amazonaws.com"
}

output "comprehend_endpoint_dns_name" {
  value = aws_comprehend_endpoint.private_endpoint.dns_name
}
