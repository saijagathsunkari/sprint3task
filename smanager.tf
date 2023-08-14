provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired VPC CIDR block
}

resource "aws_subnet" "main" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"  # Adjust the CIDR blocks as needed
  availability_zone = "us-east-1a"  # Replace with your desired availability zone in the region
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix = "vpc-endpoint-sg-"

  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids         = aws_subnet.main[*].id
}

resource "aws_secretsmanager_secret" "example" {
  name = "my-secret"
}

resource "aws_secretsmanager_secret_policy" "example" {
  secret_id = aws_secretsmanager_secret.example.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Effect   = "Allow"
        Principal = "*"
        Resource = "*"
        Condition = {
          "IpAddress": {
            "aws:SourceIp": aws_vpc_endpoint.secrets_manager.network_interface_ids[*].private_ip
          }
        }
      }
    ],
  })
}

variable "aws_region" {
  default = "us-east-1"  # Replace with your desired AWS region
}
