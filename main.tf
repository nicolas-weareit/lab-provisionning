terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}
data "aws_ami" "weare-devops-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["weare-packer-dev*"]
    }
    owners = ["063871686173"]
}
resource "aws_instance" "devops_server" {
  ami           = data.aws_ami.weare-devops-ami.id
  instance_type = "t2.micro"

  tags = {
    Name        = "devops-server"
    Provisioner = "Terraform"
    Cost_center = "LAB"
    Team = "DevOps"
  }
}