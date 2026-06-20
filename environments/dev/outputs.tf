output "cluster_name" { 
    value =  module.eks.cluster_name
}

output "cluster_endpoint" {
    value = module.eks.cluster_endpoint  
}
output "karpenter_controller_role_arn" {
    value = module.iam.karpenter_role_arn  
}
output "karpenter_node_role_arn" {
    value = module.iam.karpenter_node_role_arn  
}
output "alb_controller_role_arn" {
    value = module.iam.alb_controller_role_arn 
}
output "cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}
output "karpenter_node_role_name" {
    value = module.iam.karpenter_node_role_name  
}