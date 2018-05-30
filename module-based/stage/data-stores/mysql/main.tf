terraform {
  backend "s3" {
    encrypt = true
    bucket  = "saif-timam-terraform"
    region  = "us-west-2"
    key     = "stage/data-stores/mysql/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "example_database"
  username          = "admin"
  password          = "${var.db_password}"
}
