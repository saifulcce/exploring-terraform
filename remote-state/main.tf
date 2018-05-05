provider "aws" {
    region = "us-west-2"
}

resource "aws_s3_bucket" "terraform-state" {
    bucket = "saif-timam-terraform"

    versioning {
        enabled = true
    }

    lifecycle {
        prevent_destroy = true
    }
}