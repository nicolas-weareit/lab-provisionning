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
  count = 1
  associate_public_ip_address = true
  subnet_id = element(var.k8s_subnets_config.*.id, count.index)
  vpc_security_group_ids = ["${var.k8s-controller_security_group}"]
  key_name = "${var.environment}-k8s-key"
  user_data = <<EOF
#!/bin/bash -xe
sudo apt update
sudo apt upgrade -y
sudo hostnamectl set-hostname controller-${count.index}.${var.domain_name}
wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"

tar -xvf etcd-v3.4.15-linux-amd64.tar.gz
sudo mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/

wget -q --show-progress --https-only --timestamping \
  "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-apiserver" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-controller-manager" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-scheduler" \
  "https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl"


chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl
sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

sudo reboot
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
sudo apt-get -y install socat conntrack ipset
wget -q --show-progress --https-only --timestamping \
  https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.21.0/crictl-v1.21.0-linux-amd64.tar.gz \
  https://github.com/opencontainers/runc/releases/download/v1.0.0-rc93/runc.amd64 \
  https://github.com/containernetworking/plugins/releases/download/v0.9.1/cni-plugins-linux-amd64-v0.9.1.tgz \
  https://github.com/containerd/containerd/releases/download/v1.4.4/containerd-1.4.4-linux-amd64.tar.gz \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubectl \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kube-proxy \
  https://storage.googleapis.com/kubernetes-release/release/v1.21.0/bin/linux/amd64/kubelet

sudo mkdir -p \
  /etc/cni/net.d \
  /opt/cni/bin \
  /var/lib/kubelet \
  /var/lib/kube-proxy \
  /var/lib/kubernetes \
  /var/run/kubernetes

mkdir containerd
tar -xvf crictl-v1.21.0-linux-amd64.tar.gz
tar -xvf containerd-1.4.4-linux-amd64.tar.gz -C containerd
sudo tar -xvf cni-plugins-linux-amd64-v0.9.1.tgz -C /opt/cni/bin/
sudo mv runc.amd64 runc
chmod +x crictl kubectl kube-proxy kubelet runc 
sudo mv crictl kubectl kube-proxy kubelet runc /usr/local/bin/
sudo mv containerd/bin/* /bin/

sudo reboot
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