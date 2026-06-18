terraform {
  backend "s3" {
    bucket       = "tf-state-030179310796"
    key          = "bootstrap/terraform.tfstate"
    region       = "us-west-2"
    use_lockfile = true

  }
}