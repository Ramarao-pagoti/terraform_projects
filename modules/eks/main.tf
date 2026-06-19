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

resource "aws_eks_node_group" "system" {
    cluster_name = aws_eks_cluster.this.name
    node_group_name = "$var.environment}-system-ng"
    node_role_arn = var.node_role_arn
    subnet_ids = var.private_subnet_ids
    capacity_type = "ON_DEMAND"
    ami_type = "AL2023_x86_64_STANDARD"
    instance_types = ["t3.medium"]
    scaling_config {
      desired_size = 2
      min_size = 2
      max_size = 5
    }
    update_config {
      max_unavailable = 1
    }
    depends_on = [ aws_eks_cluster.this ]
}