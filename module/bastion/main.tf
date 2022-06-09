# Pickup the proper AMI
data "aws_ami" "devops-bastion-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["063871686173"]
}

data "aws_subnet" "public_subnet" {
  filter {
    name = "tag:Name"
    values = ["${var.environment}-*-public-subnet"]
  }
  depends_on = [module.Networking]
}

resource "aws_network_interface" "bastion_network_interface" {
  count = length(var.public_subnets_cidr)
  subnet_id = element(data.aws_subnet.public_subnet.*.id, count.index)
  tags = {
    name = "network_interface-${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = "${var.environment}"
    Team = "DevOps"
    Environment = "${var.environment}"
  }
  depends_on = [module.Networking]
}
resource "aws_instance" "devops_bastion" {
  ami           = data.aws_ami.devops-bastion-ami.id
  count         = length(var.availability_zones)
  instance_type = "t2.micro"
  hibernation   = true
  network_interface {
    network_interface_id = element(aws_network_interface.bastion_network_interface.*.id, count.index)
    device_index         = 0
  }

  tags = {
    name = "bastion-${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
  depends_on = [module.Networking]
}