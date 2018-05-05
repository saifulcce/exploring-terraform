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

output "s3_bucket_arn" {
    value = "${aws_s3_bucket.terraform_state.arn}"
}