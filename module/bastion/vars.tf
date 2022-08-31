variable "environment" {
  description = "Deployment Environment"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "CIDR block for Public Subnet"
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

variable "ami_owner" {
  description = "AMI owner to use to build Bastion server"
}

variable "instance-type-bastion" {
  description = "AWS instance type"
}

variable "public_subnets_config" {
  description = "List of created public subnets"
}

variable "public_security_group" {
  description = "Public subnets dedciated security group"
}

variable "domain_name" {
  description = "FQDN to use"
}

variable "route53_id" {
  description = "route53 ID"
}