provider "aws" {
	region = "us-west-2"
}

variable "server_port" {
	description = "The port the server will use for HTTP requests"
	default = 8080
}

data "aws_availability_zones" "all" {}

resource "aws_security_group" "instance" {
    name = "terraform-testing-SG"
    ingress {
        from_port = "${var.server_port}"
        to_port = "${var.server_port}"
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    lifecycle {
        create_before_destroy = true
    }
}


resource "aws_launch_configuration" "terraform-testing-launch-config" {
	image_id = "ami-4e79ed36"
	instance_type = "t2.micro"
	security_groups = ["${aws_security_group.instance.id}"]
	user_data = <<-EOF
		#!/bin/bash
		echo "Hello, World" > index.html
		nohup busybox httpd -f -p "${var.server_port}" &
		EOF
	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group" "elb" {
	name = "terraform-testing-elb-security-group"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}



resource "aws_elb" "terraform-Testing-ELB" {
	name = "terraform-testing-ELB"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	security_groups = ["${aws_security_group.elb.id}"]
	listener {
		lb_port = 80
		lb_protocol = "http"
		instance_port = "${var.server_port}"
		instance_protocol = "http"
	}
	health_check {
		healthy_threshold = 2
		unhealthy_threshold = 2
		timeout = 3
		interval = 30
		target = "HTTP:${var.server_port}/"
	}
}



resource "aws_autoscaling_group" "terraform-testing-ASGroup" {
	launch_configuration = "${aws_launch_configuration.terraform-testing-launch-config.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	
	load_balancers = ["${aws_elb.terraform-Testing-ELB.name}"]
	health_check_type = "ELB"

	min_size = 2
	max_size = 10
	tag {
		key = "Name"
		value = "terraform-testing-ASG"
		propagate_at_launch = true
	}
}

output "elb_dns_name" {
	value = "${aws_elb.terraform-Testing-ELB.dns_name}"
}

