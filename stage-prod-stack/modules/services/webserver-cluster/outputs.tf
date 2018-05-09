output "elb_dns_name" {
    value = "${aws_elb.firstelb.dns_name}"
}
