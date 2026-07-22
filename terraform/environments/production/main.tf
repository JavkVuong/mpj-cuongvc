data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

module "ecr" {
  source = "../../modules/ecr"

  repository_name      = "news-cms"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
}
