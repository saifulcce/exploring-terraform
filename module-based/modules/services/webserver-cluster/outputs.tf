output "elb_dns_name" {
  value = "${aws_elb.elastic-lb.dns_name}"
}

output "asg_name" {
  value = "${aws_autoscaling_group.auto-grp.name}"
}

output "elb_security_group_id" {
  value = "${aws_security_group.elb-sg.id}"
}
