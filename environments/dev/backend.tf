terraform {
  backend "s3" {
    bucket = "tf-state-030179310796"
    key = "dev/networking/terraform.tfstate"
    region = "us-west-2"
    use_lockfile = true
  }
}