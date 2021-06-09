provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  version = "= 2.18.0"
  email   = var.cloudflare_email
  api_key = var.cloudflare_token
}

provider "local" {
  version = "~> 2.0.0"
}

provider "null" {
  version = "~> 3.0.0"
}

provider "template" {
  version = "~> 2.2.0"
}

terraform {
  required_version = "~> 0.12.0"

  required_providers {
    aws = "~> 2.9"
  }

}
