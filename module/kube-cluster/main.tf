# Create simple controller node and 2 workers
data "aws_ami" "weare-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    #owners = ["170619833643"]
    owners = ["${var.ami_owner}"]
}

resource "aws_instance" "k8s-controller_instance" {
  ami           = data.aws_ami.weare-ami.id
  instance_type = "${var.instance-type-controller}"
  root_block_device {
    volume_size = 40
  }
  # hibernation   = true
  count = 1
  associate_public_ip_address = true
  subnet_id = element(var.k8s_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.k8s-controller_security_group}"]
  key_name = "${var.environment}-k8s-key"
  tags = {
    Name = "controller${count.index + 1}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

resource "aws_instance" "k8s-node_instance" {
  ami           = data.aws_ami.weare-ami.id
  instance_type = "t3a.medium"
  # hibernation   = true
  count = 2
  associate_public_ip_address = true
  subnet_id = element(var.k8s_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.k8s-node_security_group}"]
  key_name = "${var.environment}-k8s-key"
  tags = {
    Name = "k8s-node-${count.index + 1}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}