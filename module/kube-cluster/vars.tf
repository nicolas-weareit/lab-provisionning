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
  description = "Region in which the k8s host will be launched"
}

variable "availability_zones" {
  type        = list
  description = "AZ in which all the resources will be deployed"
}

variable "ami_name" {
  description = "AMI name to use to build k8s server"
}

variable "ami_owner" {
  description = "AMI owner to use to build k8s server"
}

variable "k8s_subnets_config" {
  description = "List of created k8s subnets"
}

variable "k8s-controller_security_group" {
  description = "k8s controller node dedicated security group"
}

variable "k8s-node_security_group" {
  description = "k8s simple node dedicated security group"
}

variable "instance-type-worker" {
  description = "Instance type for K8s worker node"
}

variable "instance-type-controller" {
  description = "Instance type for K8s controller node"
}