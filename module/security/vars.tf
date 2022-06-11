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

variable "private_subnets_cidr" {
  type        = list
  description = "CIDR block for Private Subnet"
}