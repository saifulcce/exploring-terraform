terraform {
    backend "s3" {
        encrypt = true
        bucket = "saif-timam-terraform"
        region = "us-west-2"
        key = "stage/services/webserver-cluster/terraform.tfstate"
    }
}


provider "aws" {
    region = "us-west-2"
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"
}

data "aws_availability_zones" "all" {}

resource "aws_security_group" "servers" {
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

### Take Database parameter from output of datastore script which stores in S3 terraform.tfstate file.

data "terraform_remote_state" "db" {
	backend = "s3"
	config {
	bucket = "saif-timam-terraform"
	key  = "stage/data-stores/mysql/terraform.tfstate"
	region = "us-west-2"
	}
}


###
data "template_file" "user_data" {
	template = "${file("user-data.sh")}"
	vars {
		server_port = "${var.server_port}"
		db_address  = "${data.terraform_remote_state.db.address}"
		db_port  = "${data.terraform_remote_state.db.port}"
	}
}

resource "aws_security_group" "firstelb" {
    name = "terraform-elb-SG"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_elb" "firstelb" {
    name               = "terraform-asg-test"
    availability_zones = ["${data.aws_availability_zones.all.names}"]
    security_groups     = ["${aws_security_group.firstelb.id}"]

    listener {
        lb_port           = 80
        lb_protocol       = "http"
        instance_port     = "${var.server_port}"
        instance_protocol = "http"
    }

    health_check {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 3
        interval            = 30
        target              = "HTTP:${var.server_port}/"
    }
}


resource "aws_launch_configuration" "alcf" {
    image_id        = "ami-4e79ed36"
    instance_type   = "t2.micro"
    security_groups = ["${aws_security_group.servers.id}"]
    user_data = "${data.template_file.user_data.rendered}"
    lifecycle{
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "asg" {
    launch_configuration = "${aws_launch_configuration.alcf.id}"
    availability_zones = ["${data.aws_availability_zones.all.names}"]

    load_balancers = ["${aws_elb.firstelb.name}"]
    health_check_type = "ELB"

    min_size = 2
    max_size = 4

    tag {
        key                 = "Name"
        value               = "terraform-asg-test"
        propagate_at_launch = true
    }
}
