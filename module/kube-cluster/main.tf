# Create simple Master node and 2 workers
data "aws_ami" "weare-ami" {
    most_recent = true
    filter {
        name = "name"
        values = ["${var.ami_name}"]
    }
    owners = ["063871686173"]
}

resource "aws_instance" "k8s-master_instance" {
  ami           = data.aws_ami.weare-ami.id
  instance_type = "t2.micro"
  # hibernation   = true
  associate_public_ip_address = false
  subnet_id = var.private_subnets_config.1.id
  vpc_security_group_ids = ["${var.private_security_group}"]
  key_name = "${var.environment}-k8s-key"
  tags = {
    Name = "k8s-master"
    Environment = "${var.environment}"
    Provisioner = "Terraform"
    Cost_center = var.environment
    Team = "DevOps"
    Environment = var.environment
  }
}