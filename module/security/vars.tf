variable "vpc_id" {
  description = "Created VPC id"
}
variable "environment" {
  description = "Deployment Environment"
}

variable "public_subnets_cidr" {
  type        = list
  description = "CIDR block for Public Subnet"
}

variable "k8s_subnets_cidr" {
  type        = list
  description = "CIDR block for k8s Subnet"
}