output "aws-public-subnets" {
  value = aws_subnet.public_subnet
  description = "List of created public subnets"
}

output "aws-private-subnets" {
  value = aws_subnet.private_subnet
  description = "List of created private subnets"
}

output "default_security_group_id" {
  value = aws_security_group.default.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}