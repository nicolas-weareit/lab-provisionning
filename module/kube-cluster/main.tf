# Create simple Master node and 2 workers
data "aws_ami" "weare-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["063871686173"]
}

#resource "aws_network_interface" "k8s-master_network_interface" {
#  subnet_id = var.private_subnets_config.1.id
#  security_groups = ["${var.private_security_group}"]
#  tags = {
#    name = "k8s-master_network_interface"
#    Environment = "${var.environment}"
#    Provisioner = "Terraform"
#    Cost_center = "${var.environment}"
#    Team = "DevOps"
#    Environment = "${var.environment}"
#  }
#}

resource "aws_instance" "k8s-master_instance" {
  ami           = data.aws_ami.weare-ami.id
  instance_type = "t2.micro"
  # hibernation   = true
  associate_public_ip_address = false
  subnet_id = var.private_subnets_config.1.id
  vpc_security_group_ids = ["${var.private_security_group}"]
  # network_interface {
  #  network_interface_id = aws_network_interface.k8s-master_network_interface.id
  #  device_index         = 0
  #}
  tags = {
    Name = "k8s-master"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}