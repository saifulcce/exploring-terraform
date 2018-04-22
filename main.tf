provider "aws" {
region = "us-west-2"
}

resource "aws_instance" "shaiful-instance1" {
ami = "ami-d874e0a0"
instance_type = "t2.micro"
tags {
Name = "test-webserver"
}
}
