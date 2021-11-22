##Allows EC2 instances to apt-update withouth having public IPs (aka NAT)

resource "aws_eip" "public" {
 vpc   = true
 tags = merge(var.aws_build_tags, {Name = "${var.name}_public"})
}

resource "aws_nat_gateway" "public_nat" {
  connectivity_type = "public"
  allocation_id = aws_eip.public.id
  subnet_id = "${var.public_subnet_id}"
  tags = merge(var.aws_build_tags, {Name = "${var.name}_public"})
}

resource "aws_route" "private_to_publicnat" {
  route_table_id="${var.private_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"             
  nat_gateway_id = aws_nat_gateway.public_nat.id
}

resource "aws_route" "manage_to_publicnat" {
  route_table_id="${var.manage_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"             
  nat_gateway_id = aws_nat_gateway.public_nat.id
}