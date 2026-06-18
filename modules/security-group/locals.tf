locals {
  common_tags = {
    Project = "ecommerce-platform"
    Environment = var.environment
    managed_by = "Terraform"
  }
}