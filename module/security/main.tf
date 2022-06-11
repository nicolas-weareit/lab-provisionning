# Create and manage security groups and so key pair (?)

# Allow ports from outside to public subnets
resource "aws_security_group" "public_subnet_allowed" {
  name = "${var.environment}-public-subnets-sg"
  description = "Allowed incoming ports"
  vpc_id = var.vpc_id
  ingress {
    description = "SSH allowed"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS allowed"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-public-subnets-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Allow ports from public subnet to private ones
resource "aws_security_group" "private_subnet_allowed" {
  name = "${var.environment}-private-subnets-sg"
  description = "Allowed incoming ports"
  vpc_id = var.vpc_id
  ingress {
    description = "SSH allowed"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.public_subnets_cidr
  }
  ingress {
    description = "HTTPS allowed"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = var.public_subnets_cidr
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-private-subnets-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}