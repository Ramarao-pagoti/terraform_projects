resource "aws_eks_cluster" "this" {
  name = "${var.environment}-eks-cluster"
  role_arn = var.cluster_role_arn
  version = "1.33"
  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access = true
  }
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}