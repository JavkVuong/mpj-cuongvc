provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "news-cms"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}
