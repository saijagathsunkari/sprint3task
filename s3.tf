provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
  # Add other AWS credentials and configurations as needed
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired VPC CIDR block
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"  # Replace with your desired subnet CIDR block
  availability_zone = "us-east-1a"   # Replace with your desired availability zone in the region
}

resource "aws_s3_bucket" "bucket" {
  bucket = "your-s3-bucket-name"  # Replace with your desired S3 bucket name
  acl    = "private"
  # Add any other S3 bucket configurations as needed
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.s3"  # Replace with your desired AWS region

  security_group_ids = [aws_security_group.s3_endpoint.id]

  vpc_endpoint_type = "Interface"

  subnet_ids = [aws_subnet.main.id]
}

resource "aws_security_group" "s3_endpoint" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "aws_region" {
  default = "us-east-1"  # Replace with your desired AWS region
}
