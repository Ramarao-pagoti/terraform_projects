module "s3_backend" {
  source = "./modules/s3_backend"
  bucket_name = "tf-state-030179310796"
}

module "terraform-role" {
  source = "./modules/terraform-role"
  user_arn = "arn:aws:iam::030179310796:user/ramarao"
  role_name = "Terraform-execution-role"
}