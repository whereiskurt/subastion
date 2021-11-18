resource "aws_vpc" "golden" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.aws_build_tags, {Name = "golden"})
}

resource "aws_internet_gateway" "public" {    
  vpc_id =  aws_vpc.golden.id               
  tags = merge(var.aws_build_tags, {Name = "golden"})
}

resource "aws_subnet" "public" {
  depends_on = [aws_internet_gateway.public]
  vpc_id =  aws_vpc.golden.id
  cidr_block = "${var.public_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "golden_public"})
}

resource "aws_eip" "public" {
  vpc   = true
  tags = merge(var.aws_build_tags, {Name = "golden_public"})
}

resource "aws_route_table" "public_internet" {
  vpc_id =  aws_vpc.golden.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
  tags = merge(var.aws_build_tags, {Name = "golden_public"})
}

# resource "aws_nat_gateway" "public_nat" {
#   depends_on = [aws_internet_gateway.public]
#   connectivity_type = "public"
#   allocation_id = aws_eip.public.id
#   subnet_id = aws_subnet.public.id
#   tags = merge(var.aws_build_tags, {Name = "golden_public"})
# }

resource "aws_route_table_association" "public_internet" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_internet.id
}

resource "aws_subnet" "manage" {
  vpc_id =  aws_vpc.golden.id
  cidr_block = "${var.manage_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "golden_manage"})
}

resource "aws_subnet" "private" {
  vpc_id =  aws_vpc.golden.id
  cidr_block = "${var.private_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "golden_private"})
}

resource "aws_route_table" "private" {
  tags = merge(var.aws_build_tags, 
    { Name = "golden_private", 
      Description ="Traffic heading to 0.0.0.0 will end up coming out of the NAT." }
  )

  vpc_id = aws_vpc.golden.id
  #route {
  #  cidr_block = "0.0.0.0/0"             
  #  nat_gateway_id = aws_nat_gateway.public_nat.id
  #}
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "manage" {
  subnet_id = aws_subnet.manage.id
  route_table_id = aws_route_table.manage.id
}

resource "aws_route_table" "manage" {
  vpc_id = aws_vpc.golden.id
  # route {
  #   cidr_block = "0.0.0.0/0"             
  #   nat_gateway_id = aws_nat_gateway.public_nat.id
  # }
  tags = merge(var.aws_build_tags, {Name = "golden_manage"})
}

resource "aws_default_network_acl" "default" {
  tags = merge(var.aws_build_tags, {Name = "golden_default"})

  default_network_acl_id = aws_vpc.golden.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
