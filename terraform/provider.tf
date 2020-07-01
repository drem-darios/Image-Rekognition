provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 0.12.0" # introduction of Local Values configuration language feature

  backend "s3" {
  }
}