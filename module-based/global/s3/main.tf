terraform {
  backend "s3" {
    encrypt = true
    bucket  = "saif-timam-terraform"
    region  = "us-west-2"
    key     = "terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "saif-timam-terraform"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
