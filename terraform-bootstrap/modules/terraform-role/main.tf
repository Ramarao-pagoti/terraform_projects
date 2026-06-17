data "aws_iam_policy_document" "admin_role_policy" {
    statement {
        effect = "Allow"

        principals {
            type        = "AWS"
            identifiers = [var.user_arn]
        }

        actions = ["sts:AssumeRole"]
    }
}



resource "aws_iam_role" "Terraform-execution-role_for_User" {
	name               = var.role_name
	assume_role_policy = data.aws_iam_policy_document.admin_role_policy.json
}

resource "aws_iam_role_policy_attachment" "Terraform-execution-role-policy-attachment" {
  role       = aws_iam_role.Terraform-execution-role_for_User.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}