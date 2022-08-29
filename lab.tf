#resource "random_id" "random_id_prefix" {
#  byte_length = 2
#}

locals {
  lab_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "Networking" {
  source               = "./module/networking"
  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  k8s_subnets_cidr = var.k8s_subnets_cidr
  availability_zones   = local.lab_availability_zones
}

module "Security" {
  source = "./module/security"
  depends_on = [module.Networking]
  environment   = var.environment
  public_subnets_cidr  = var.public_subnets_cidr
  k8s_subnets_cidr = var.k8s_subnets_cidr
  vpc_id = module.Networking.vpc_id
}
module "Bastion" {
  source                = "./module/bastion"
  depends_on            = [
    module.Networking,
    module.Security
  ]
  region                = var.region
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidr   = var.public_subnets_cidr
  availability_zones    = local.lab_availability_zones
  ami_name              = var.lab_ami_name
  ami_owner             = var.lab_k8s-ami_owner
  instance-type-bastion = var.lab_bastion_instance-type
  public_subnets_config = module.Networking.aws-public-subnets
  public_security_group = module.Security.public_security_group_id
}

module "Kube-cluster" {
  source                = "./module/kube-cluster"
  depends_on            = [
    module.Networking,
    module.Security
  ]
  region                          = var.region
  environment                     = var.environment
  vpc_cidr                        = var.vpc_cidr
  k8s_subnets_cidr                = var.k8s_subnets_cidr
  availability_zones              = local.lab_availability_zones
  ami_name                        = var.lab_k8s-ami_name
  ami_owner                       = var.lab_k8s-ami_owner
  instance-type-controller        = var.lab_instance-type-controller
  instance-type-worker            = var.lab_instance-type-worker
  k8s_subnets_config              = module.Networking.aws-k8s-subnets
  k8s-controller_security_group   = module.Security.k8s-controller_security_group_id
  k8s-node_security_group         = module.Security.k8s-node_security_group_id
}