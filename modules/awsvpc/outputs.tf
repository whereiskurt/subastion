output "public_subnet_id" {
  value = "${aws_subnet.public.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private.id}"
}

output "manage_subnet_id" {
  value = "${aws_subnet.manage.id}"
}

output "vpc_id" {
  value = "${aws_vpc.golden.id}"
}

