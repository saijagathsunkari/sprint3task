provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired VPC CIDR block
}

resource "aws_subnet" "main" {
  count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "us-east-1a"  # Replace with your desired availability zone
}

resource "aws_comprehend_medical_endpoint" "private_link" {
  name = "comprehend-medical-endpoint"
  security_group_ids = [aws_security_group.comprehend_medical.id]
  subnet_ids         = aws_subnet.main[*].id
}

resource "aws_security_group" "comprehend_medical" {
  name_prefix = "comprehend-medical-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this to your security requirements
  }
}

output "comprehend_medical_endpoint_id" {
  value = aws_comprehend_medical_endpoint.private_link.id
}
