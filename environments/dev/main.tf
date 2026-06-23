 
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
  oidc_issuer_url = module.eks.oidc_issuer_url
}

module "eks" {
  source = "../../modules/eks"
  environment = var.environment
  private_subnet_ids = module.vpc.private_app_subnet_ids
  node_role_arn = module.iam.eks_node_role_arn
  cluster_role_arn = module.iam.eks_cluster_role_arn
  eks_node_sg_id = module.security-group.eks_nodes_sg_id
}

module "argocd" {
  source = "../../modules/argocd"
  cluster_name = module.eks.cluster_name  
}

module "route53" {
  source = "../../modules/route53"
  domain_name = "mybanking.shop"
  environment = var.environment
}


resource "aws_ec2_tag" "karpenter_cluster_sg_discovery" {
  resource_id = module.eks.cluster_security_group_id

  key   = "karpenter.sh/discovery"
  value = module.eks.cluster_name
}

