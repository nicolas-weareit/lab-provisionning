# Pickup the proper AMI
data "aws_ami" "devops-bastion-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["${var.ami_owner}"]
}
# Create bastion server
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
#!/bin/bash -xe
sudo apt update
sudo apt upgrade -y
sudo hostnamectl set-hostname bastion${count.index}.${var.domain_name}


EOF
  tags = {
    Name = "bastion${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Add DNS entry for ressource
resource "aws_route53_record" "dns_bastion" {
  count = 1
  zone_id = var.route53_id
  name = "bastion${count.index}.${var.domain_name}"
  type = "A"
  ttl = "60"
  records = ["${element(aws_instance.devops_bastion.*.private_ip, count.index)}"]
}