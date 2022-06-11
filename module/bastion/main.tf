# Pickup the proper AMI
data "aws_ami" "devops-bastion-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["063871686173"]
}

resource "aws_network_interface" "bastion_network_interface" {
  count = length(var.public_subnets_cidr)
  subnet_id = element(var.public_subnets_config.*.id, count.index)
  security_groups = ["${var.public_security_group}"]
  tags = {
    name = "network_interface-${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = "${var.environment}"
    Team = "DevOps"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "devops_bastion" {
  ami           = data.aws_ami.devops-bastion-ami.id
  count         = (length(var.availability_zones)-1)
  instance_type = "t2.micro"
  # hibernation   = true
  key_name = "EC2Tutorial"
  network_interface {
    network_interface_id = element(aws_network_interface.bastion_network_interface.*.id, count.index)
    device_index         = 0
  }
  tags = {
    Name = "bastion-${count.index + 1}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}