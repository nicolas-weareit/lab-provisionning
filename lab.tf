resource "random_id" "random_id_prefix" {
  byte_length = 2
}

locals {
  lab_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  lab_ami_name = "weare-packer-dev-aws"
  lab_k8s-ami_name = "weare-packer-k8s"
}

module "Networking" {
  source               = "./module/networking"
  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.lab_availability_zones
}

module "Security" {
  source = "./module/security"
  depends_on = [module.Networking]
  environment   = var.environment
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
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
  private_subnets_cidr  = var.private_subnets_cidr
  availability_zones    = local.lab_availability_zones
  ami_name              = local.lab_ami_name
  public_subnets_config = module.Networking.aws-public-subnets
  public_security_group = module.Security.public_security_group_id
}

module "Kube-cluster" {
  source                = "./module/kube-cluster"
  depends_on            = [
    module.Networking,
    module.Security
  ]
  region                  = var.region
  environment             = var.environment
  vpc_cidr                = var.vpc_cidr
  private_subnets_cidr    = var.private_subnets_cidr
  availability_zones      = local.lab_availability_zones
  ami_name                = local.lab_k8s-ami_name
  private_subnets_config  = module.Networking.aws-private-subnets
  private_security_group  = module.Security.private_security_group_id
}