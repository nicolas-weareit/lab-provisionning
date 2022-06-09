output "aws-public-subnets" {
  value = aws_subnet.public_subnet
  description = "List of created public subnets"
}