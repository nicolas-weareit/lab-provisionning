# Module to create appropriate IAM roles for the lab

# Create policy for read only access on EC2 instances
resource "aws_iam_policy" "policy_ec2_ro" {
  name = "ec2-readOnly"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:Describe*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Create bastion IAM roles
resource "aws_iam_role" "lab_bastion_role" {
  name = "bastion-ec2-readonly"
  description = "Provide read only acces to EC2 information"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [aws_iam_policy.policy_ec2_ro.arn]

  tags = {
    Name = "bastion-ec2-readonly"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.lab_bastion_role.name
}