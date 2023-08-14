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
  availability_zone = "us-east-1a"  # Replace with your desired availability zone(s)
}

resource "aws_security_group" "textract_sg" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust to match your VPC CIDR range
  }

  // Add any additional inbound rules as needed
}

resource "aws_vpc_endpoint" "textract_endpoint" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.textract.amazonaws.com"  # Replace with the appropriate service name for your region
  subnet_ids   = aws_subnet.main[*].id

  security_group_ids = [
    aws_security_group.textract_sg.id,
  ]
}

output "textract_endpoint_dns" {
  value = aws_vpc_endpoint.textract_endpoint.dns_entry
}
