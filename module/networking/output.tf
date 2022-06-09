output "aws-public-subnets" {
  value = aws_subnet.public_subnet
  description = "List of created public subnets"
}

output "default_security_group_id" {
    value = aws_security_group.default.id
}