output "vpc_id" {
  value = "${aws_vpc.golden.id}"
}
output "default_network_acl_id" {
  value = "${aws_vpc.golden.default_network_acl_id}"
}
