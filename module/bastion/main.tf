# Pickup the proper AMI
data "aws_ami" "devops-bastion-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["${var.ami_owner}"]
}

resource "aws_instance" "devops_bastion" {
  ami           = data.aws_ami.devops-bastion-ami.id
  # count         = (length(var.availability_zones)-1)
  count = 1
  instance_type = "${var.instance-type-bastion}"
  subnet_id = element(var.public_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.public_security_group}"]
  # hibernation   = true
  key_name = "${var.environment}-bastion-key"
  user_data = <<EOF
  #!/bin/bash
  echo "Changing Hostname"
  hostname "bastion${count.index}"
  echo "bastion${count.index}" > /etc/hostname
  EOF
  tags = {
    Name = "bastion${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}