terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    profile = "AudienceServAWS"
    bucket  = "as-terraform-backends"
    key     = "state/moon/pipelines/dev.tfstate"
    region  = "eu-west-1"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "AudienceServAWS"

  default_tags {
    tags = {
      app_environment = var.app_environment
      app_name        = var.app_name
      terraform       = "true"
    }
  }
}