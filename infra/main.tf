provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "ilynch-capproj-bucket"
    key = "prod/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
}

module "ssh" {
  source = "./modules/ssh"
  ssh_key_name      = var.ssh_key_name
  ssh_public_key    = var.ssh_public_key
  ssh_private_key   = var.ssh_private_key
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.subnet_ids
  ssh_key_name       = module.ssh.key_name
  security_group_id = module.network.app_security_group_id
  ami_id             = var.ami_id
  instance_type      = var.instance_type
}

module "load_balancer" {
  source          = "./modules/load_balancer"
  vpc_id          = module.network.vpc_id
  subnet_ids      = module.network.subnet_ids
  instances       = module.compute.app_instance_ids
  lb_security_group_ids = module.network.lb_security_group_id
  availability_zones = var.availability_zones

  # Transform list of instance IDs into a map
  instance_ids = zipmap(
    ["instance1", "instance2"],  # Keys (you can add more if needed)
    module.compute.app_instance_ids  # List of actual instance IDs
  )
}

output "application_instance_ips" {
  value = module.compute.application_instance_ips
}

output "jenkins_instance_ips" {
  value = module.compute.jenkins_instance_ips
}

output "load_balancer_dns" {
  value = module.load_balancer.dns_name
}
