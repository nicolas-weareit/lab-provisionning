output "public_security_group_id" {
  value = aws_security_group.public_subnet_allowed.id
}

output "k8s_security_group_id" {
  value = aws_security_group.k8s_subnet_allowed.id
}