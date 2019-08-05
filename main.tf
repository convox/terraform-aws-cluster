terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = "~> 2.22"
  region  = var.region
}
