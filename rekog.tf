provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired VPC CIDR block
}
resource "aws_security_group" "rekognition" {
  vpc_id = aws_vpc.main.id

  // Ingress and egress rules for Rekognition API traffic
  // Adjust rules as needed
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Restrict this to a more specific range if possible
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  // Restrict this to a more specific range if possible
  }
}
resource "aws_vpc_endpoint" "rekognition" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.rekognition"  # Replace with the correct region if different

  security_group_ids = [aws_security_group.rekognition.id]
}
resource "aws_vpc_endpoint_subnet_association" "rekognition" {
  for_each      = aws_subnet.main[*].id
  subnet_id     = each.value
  vpc_endpoint_id = aws_vpc_endpoint.rekognition.id
}
resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"  # Replace with your desired subnet CIDR block
  availability_zone       = "us-east-1a"   # Replace with your desired availability zone in the region
}
