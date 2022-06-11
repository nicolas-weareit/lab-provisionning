variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "private_subnets_cidr" {
  type        = list
  description = "CIDR block for Private Subnet"
}

variable "region" {
  description = "Region in which the bastion host will be launched"
}

variable "availability_zones" {
  type        = list
  description = "AZ in which all the resources will be deployed"
}

variable "ami_name" {
  description = "AMI name to use to build Bastion server"
}

variable "private_subnets_config" {
  description = "List of created private subnets"
}

variable "private_security_group" {
  description = "Private subnets dedciated security group"
}