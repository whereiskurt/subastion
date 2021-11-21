resource "aws_vpc" "golden" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.aws_build_tags, {Name = "golden"})
}