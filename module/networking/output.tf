output "aws-public-subnets" {
  value = aws_subnet.public_subnet
  description = "List of created public subnets"
}

output "aws-k8s-subnets" {
  value = aws_subnet.k8s_subnet
  description = "List of created k8s subnets"
}

output "default_security_group_id" {
  value = aws_security_group.default.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}