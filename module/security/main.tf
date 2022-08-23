# Create and manage security groups and so key pair (?)
# Allow ports from outside to public subnets
resource "aws_security_group" "bastion_allowed" {
  name = "${var.environment}-bastion-sg"
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
    Name = "${var.environment}-bastion-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Allow ports from public subnet to k8s ones
resource "aws_security_group" "k8s_master" {
  name = "${var.environment}-k8s_master-sg"
  description = "Allowed incoming ports"
  vpc_id = var.vpc_id
  ingress {
    description = "SSH from bastion server"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = var.public_subnets_cidr
    security_groups = [aws_security_group.bastion_allowed.id]
  }
  ingress {
    description = "HTTPS allowed"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    # cidr_blocks = var.public_subnets_cidr
    security_groups = [aws_security_group.bastion_allowed.id]
  }

  ingress {
    description = "Kube control plane allowed"
    from_port = 6443
    to_port = 6443
    protocol = "tcp"
    # cidr_blocks = var.public_subnets_cidr
    security_groups = [aws_security_group.bastion_allowed.id]
  }

  ingress {
    description = "Allow all communication in the same vlan"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = var.k8s_subnets_cidr
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-k8s_master-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Allow ports for k8s nodes
resource "aws_security_group" "k8s_node" {
  name = "${var.environment}-k8s_node-sg"
  description = "Allowed incoming ports"
  vpc_id = var.vpc_id
  ingress {
    description = "SSH from bastion server and master nodes"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # cidr_blocks = var.public_subnets_cidr
    security_groups = [aws_security_group.bastion_allowed.id]
  }
  
  ingress {
    description = "Allow all communication in the same vlan"
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = var.k8s_subnets_cidr
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-k8s_node-sg"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Key Pair generation
resource "aws_key_pair" "k8s" {
  key_name = "${var.environment}-k8s-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4ZhuuHXWzqFhEhTdC3uN+5QYWQNrbcwyf/OGJMobPPt3UHxkIF0pPUusxyl3j2J0m+PEKCH+56ZctZ4MB3kaq/jrsBdxDKmtI0dIasA4ZfZfRBsdJAn3FFbqfnZIAyV0Kmq4MBSsM/BnG6/56b+xeMRxy83kRU8gne4B+BHd5f0FlLW9i2rcY+kqb6N3OqY8r4o7JUzpds7gUf3UkUbwSyt2EA7rpvuSvl5gX+FPo2513sZeagOmHNbSCWwCiQAZzo8QmIUcGc0IumIA07Rzpzu6JCBdLl2fswDO6DuIYOYy5gUtCZOQSR4af4ZIqmlnceEQSghnJiajU+kO5pfAPqNEcDMk15bBx8SORVasW0nGoXjn3jM8cUrxh61Jifxb6jZOPq5dGGvxkIn9TyFfEybb8W7nUBIEE4m6Q0duSCOhCk38QExF0s56Ia60AMMjCvYYdFeGnFmgH4H/caw7yNGBaMLrpffQdZhMKnVfyKZHNCGhFjQhB5HuTOX+Sdnt9NneX50mYBTFIZsWhSyDhXoPGNusWSp7Jx0ZYq6djMbWJP0Dtq687Wt4uCMSG7QkuriLWqR5Ouo8zcS6wut93hqgvlgt5omghGCy6d3tnaaHfBt00O+/hR4X3+BTYz6zU5xfAeSxy3mZ9JKnR5lnU4YpmtB+w2fS5+BT3S4gsmQ== lab-k8s"
  tags = {
    Name = "${var.environment}-k8s-key"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

resource "aws_key_pair" "bastion" {
  key_name = "${var.environment}-bastion-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDF4SAQrTX+re9B2h4zEZtPZUSIXBtLySvptR540ywb7/7A/iUh1MIsLlxDppIwH5veKphoYIZg5vslnwc9ugOvZoJm5ZoIvsW42yGLxPeCuOxAEwWlv5GdgwrgKr7wPBg/47dQYloDPrDbPFtYxEVw6ADLtxhgfwnTJyQ3UvWR7VVLQGUbxU7pk5gSUzrQKIILhEsrCwrQUDmvKSwTS9q2F/p/SCduEnoex+rU2MP7x6thX4CCWG+qE3gw2sE/iuR+4ro8PYgoIuyGyKiYUnK4pLBZpDICelaRilH2cOympFEn4/IQauurjQvC47i3LxoG0HnIk/Sxr1C7KFm0M0WxxqVvD6VmYbMEDtpGsMfC9KibaC0vn1D8GP2S9QNHebZ1zQ5mqDuO+fXdAt0wCBI4iJOuhXLOO5bXglV3D+6G54/zkiZevc4SN0htetXSfmacqp7S9yU7go1EeYAQYiHIR7bBXgtmAsoLpSkLuFXxVrBy2MvDBbegYQRSbElKfyghwyKjOR52woXWhXfey8+C8PT/y0eCNuiwxNZR1tea3bi1jxVN5YfNzjdZC6Gy7U6hdnbnji2u6Caq0UdUcIkjLNSbAr5nUO+CfXQYP40GNfjPPNGS5tguGlHdh55UMMBfff0v+k7DQkagmcUsiEYJzyDAmH2yq4PSsNxMFjNvOw== lab-bastion"
  tags = {
    Name = "${var.environment}-bastion-key"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}