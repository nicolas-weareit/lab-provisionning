variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  description = "Deployment Environment"
  default = "lab"
}

variable "vpc_cidr" {
  description = "CIDR block of the vpc"
  default     = "10.0.1.0/24"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for Public Subnet"
  default     = ["10.0.1.0/28","10.0.1.16/28","10.0.1.32/28"]
}

variable "k8s_subnets_cidr" {
  type        = list(any)
  description = "CIDR block for k8s Subnet"
  default     = ["10.0.1.128/28","10.0.1.144/28","10.0.1.160/28"]
}

variable "aws-public-subnets" {
  type        = list(any)
  description = "Created public subnets"
  default = []
}

variable "security_group" {
  description = "Security group"
  default = ""
}

variable "lab_availability_zones" {
  default = ""
}

variable "lab_ami_name" {
  default = ""
}
variable "lab_bastion_instance-type" {
  default = ""
}

variable "lab_k8s-ami_name" {
  default = ""
}

variable "lab_k8s-ami_owner" {
  default = ""
}

variable "lab_instance-type-controller" {
  default = ""
}

variable "lab_instance-type-worker" {
  default = ""
}

variable "lab_domain_name" {
  default = ""
}