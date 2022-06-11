variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "k8s_subnets_cidr" {
  type        = list
  description = "CIDR block for k8s Subnet"
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

variable "k8s_subnets_config" {
  description = "List of created k8s subnets"
}

variable "k8s_security_group" {
  description = "k8s subnets dedciated security group"
}