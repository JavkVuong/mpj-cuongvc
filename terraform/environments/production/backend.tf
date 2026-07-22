terraform {
  backend "s3" {
    bucket       = "news-cms-terraform-state-527055790396"
    key          = "production/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
