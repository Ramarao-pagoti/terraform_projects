variable "environment" {
type = string  
}
variable "cluster_role_arn" {
    type = string  
}
variable "node_role_arn" {
  type = string
}
variable "private_subnet_ids" {
    type = list(string)  
}
variable "eks_node_sg_id" {
    type = string  
}

