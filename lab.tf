resource "random_id" "random_id_prefix" {
  byte_length = 2
}

locals {
  lab_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  lab_ami_name = "weare-packer-dev-aws"
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

module "Bastion" {
  source               = "./module/bastion"
  depends_on = [module.Networking]
  region                = var.region
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  public_subnets_cidr   = var.public_subnets_cidr
  private_subnets_cidr  = var.private_subnets_cidr
  availability_zones    = local.lab_availability_zones
  ami_name              = local.lab_ami_name
  public_subnets_config = module.Networking.aws-public-subnets
}