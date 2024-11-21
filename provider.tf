provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = ">= 0.13.5"

#  backend "s3" {
#    bucket = "amazon-terraform-state-bucket"
#    key = "static-website.tfstate"
#    region = "us-east-1"
#    encrypt = "true"
#  }
}