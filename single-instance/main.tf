provider "aws" {
	region = "us-west-2"
}

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default = 8080
}

resource "aws_security_group" "instance" {
	name = "terraform-example-instance"
	ingress {
		from_port = "${var.server_port}"
		to_port = "${var.server_port}"
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
		}
}

resource "aws_instance" "test-instance1" {
	ami = "ami-4e79ed36"
	instance_type = "t2.micro"
	vpc_security_group_ids = ["${aws_security_group.instance.id}"]
	
	user_data = <<-EOF
	#!/bin/bash
	echo "Hello, World" > index.html
	nohup busybox httpd -f -p "${var.server_port}" &
	EOF
	
	tags {
	      Name = "test-webserver-01"
	     }

}

output "public_ip" {
	value = "${aws_instance.test-instance1.public_ip}"
}
