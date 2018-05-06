terraform {
    backend "s3" {
        encrypt = true
        bucket = "saif-timam-terraform"
        region = "us-west-2"
        key = "terraform.tfstate"
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

output "s3_bucket_arn" {
    value = "${aws_s3_bucket.terraform_state.arn}"
}


variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default = 8080
}

resource "aws_security_group" "instance" {
	name = "terraform-sg"
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

resource "aws_instance" "test-instance2" {
        ami = "ami-4e79ed36"
        instance_type = "t2.micro"
        vpc_security_group_ids = ["${aws_security_group.instance.id}"]

        user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World" > index.html
        nohup busybox httpd -f -p "${var.server_port}" &
        EOF

        tags {
              Name = "test-webserver-02"
             }

}


output "public_ip" {
	value = "${aws_instance.test-instance1.public_ip}"
}


