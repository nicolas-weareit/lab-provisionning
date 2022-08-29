output "public_security_group_id" {
  value = aws_security_group.bastion_allowed.id
}

output "k8s-controller_security_group_id" {
  value = aws_security_group.k8s_controller.id
}

output "k8s-node_security_group_id" {
  value = aws_security_group.k8s_node.id
}