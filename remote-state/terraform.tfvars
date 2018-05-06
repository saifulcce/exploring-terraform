terragrunt = {
  remote_state {
    backend = "s3"
    config {
      bucket         = "saif-timam-terraform"
      key            = "terraform.tfstate"
      region         = "us-west-2"
      encrypt        = true
      dynamodb_table = "my-lock-table"
    }
  }
}