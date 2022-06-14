output "public_security_group_id" {
  value = aws_security_group.bastion_allowed.id
}

output "k8s-master_security_group_id" {
  value = aws_security_group.k8s_master.id
}

output "k8s-node_security_group_id" {
  value = aws_security_group.k8s_node.id
}