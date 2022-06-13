# Pickup the proper AMI
data "aws_ami" "devops-bastion-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["063871686173"]
}

resource "aws_instance" "devops_bastion" {
  ami           = data.aws_ami.devops-bastion-ami.id
  # count         = (length(var.availability_zones)-1)
  count = 1
  instance_type = "t2.micro"
  subnet_id = element(var.public_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.public_security_group}"]
  # hibernation   = true
  key_name = "${var.environment}-bastion-key"
  tags = {
    Name = "bastion-${count.index + 1}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}