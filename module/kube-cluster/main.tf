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
    volume_size = 30
  }
  # hibernation   = true
  count = 2
  associate_public_ip_address = true
  subnet_id = element(var.k8s_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.k8s-controller_security_group}"]
  key_name = "${var.environment}-k8s-key"
  user_data = <<EOF
#!/bin/bash -xe
sudo apt update
sudo apt upgrade -y
sudo hostnamectl set-hostname controller-${count.index}.${var.domain_name}
EOF
  tags = {
    Name = "controller-${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Add DNS entry for ressource
resource "aws_route53_record" "dns_controller" {
  count = 1
  zone_id = var.route53_id
  name = "controller-${count.index}.${var.domain_name}"
  type = "A"
  ttl = "60"
  records = ["${element(aws_instance.k8s-controller_instance.*.private_ip, count.index)}"]
}

resource "aws_instance" "k8s-node_instance" {
  ami           = data.aws_ami.weare-ami.id
  instance_type = "${var.instance-type-worker}"
  # hibernation   = true
  count = 2
  associate_public_ip_address = true
  subnet_id = element(var.k8s_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.k8s-node_security_group}"]
  key_name = "${var.environment}-k8s-key"
  user_data = <<EOF
#!/bin/bash -xe
sudo apt update
sudo apt upgrade -y
sudo hostnamectl set-hostname worker-${count.index}.${var.domain_name}
EOF
  tags = {
    Name = "worker-${count.index}"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
  }
}

# Add DNS entry for ressource
resource "aws_route53_record" "dns_worker" {
  count = 2
  zone_id = var.route53_id
  name = "worker-${count.index}.${var.domain_name}"
  type = "A"
  ttl = "60"
  records = ["${element(aws_instance.k8s-node_instance.*.private_ip, count.index)}"]
}