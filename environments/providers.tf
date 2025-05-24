provider "aws" {
  alias  = "default"
  region = var.region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "dor-tfstate-bucket"
    key    = "dor-resume"
    region = "il-central-1"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.26.0"
    }
  }
}