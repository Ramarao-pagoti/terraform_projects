module "s3_backend" {
  source      = "./modules/s3_backend"
  bucket_name = "tf-state-030179310796"
}

module "terraform-role" {
  source                = "./modules/terraform-role"
  trusted_principal_arn = "arn:aws:iam::030179310796:user/ramarao"
  role_name             = "Terraform-execution-role"
}

resource "aws_iam_policy" "Terraform-execution-role-policy" {
  name        = "Terraform-execution-role-policy"
  description = "Policy for Terraform execution role"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "${module.terraform-role.role_arn}"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "Terraform-execution-role-policy-attachment" {
  user       = "ramarao"
  policy_arn = aws_iam_policy.Terraform-execution-role-policy.arn
}