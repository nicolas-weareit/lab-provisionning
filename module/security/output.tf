output "public_security_group_id" {
  value = aws_security_group.public_subnet_allowed.id
}

output "private_security_group_id" {
  value = aws_security_group.private_subnet_allowed.id
}