module "vpc" {
  source = "../../modules/VPC"
  environment = "dev"
    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b"]
}

module "security-group" {
  source = "../../modules/security-group"
  vpc_id = module.vpc.vpc_id 
}

module "ecr" {
  source = "../../modules/ecr"
  environment = var.environment
  repositories = var.repositories  
}

module "iam" {
  source = "../../modules/iam"
  environment = var.environment
}