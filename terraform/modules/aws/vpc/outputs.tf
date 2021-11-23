output "vpc_id" {
  value = aws_vpc.golden.id
}
output "internet_gateway_id" {
  value = aws_internet_gateway.public.id
}
output "subastion_security_group" {
  value=aws_security_group.subastion_public.id
}

