#Dedicated networks for the lab

# VPC creation
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name        = "${var.environment}-vpc"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}


# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.k8s_subnets_cidr)
  cidr_block              = element(var.k8s_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-k8s-subnet"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}

# Routing tables to route traffic for k8s Subnets
resource "aws_route_table" "k8s" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-k8s-route-table"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}

# Routing tables to route traffic for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}

# Route for Internet Gateway - Public Subnets
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for Internet Gateway - k8s Subnets
resource "aws_route" "k8s_internet_gateway" {
  route_table_id         = aws_route_table.k8s.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route table associations for both Public & k8s Subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "k8s" {
  count          = length(var.k8s_subnets_cidr)
  subnet_id      = element(aws_subnet.k8s_subnet.*.id, count.index)
  route_table_id = aws_route_table.k8s.id
}

# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default SG to allow traffic from the VPC"
  vpc_id      = aws_vpc.vpc.id
  
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags = {
    Name = "${var.environment}-default-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Default route53 zone
resource "aws_route53_zone" "private" {
  name = "lab.k8s.local"
  comment = "Private DNS zone for K8S cluster"
  vpc {
    vpc_id = aws_vpc.vpc.id
  }
  force_destroy = true
  tags = {
    Name = "${var.environment}-dns-private"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}
