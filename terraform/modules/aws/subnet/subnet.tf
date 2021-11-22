resource "aws_internet_gateway" "public" {    
  vpc_id =  var.vpc_id               
  tags = merge(var.aws_build_tags, {Name = "${var.name}"})
}

resource "aws_subnet" "public" {
  depends_on = [aws_internet_gateway.public]
  vpc_id =  var.vpc_id
  cidr_block = "${var.public_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "${var.name}_public"})
}

resource "aws_route_table" "public_internet" {
  vpc_id =  var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }
  tags = merge(var.aws_build_tags, {Name = "${var.name}_public"})
}

resource "aws_route_table_association" "public_internet" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_internet.id
}

resource "aws_subnet" "manage" {
  vpc_id =  var.vpc_id
  cidr_block = "${var.manage_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "${var.name}_manage"})
}

resource "aws_subnet" "private" {
  vpc_id =  var.vpc_id
  cidr_block = "${var.private_subnets}"
  availability_zone = "ca-central-1a"
  tags = merge(var.aws_build_tags, {Name = "${var.name}_private"})
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  tags = merge(var.aws_build_tags, 
    { Name = "${var.name}_private", 
      Description ="Traffic heading to 0.0.0.0 will end up coming out of the NAT." }
  )
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
  vpc_id = var.vpc_id
  tags = merge(var.aws_build_tags, {Name = "${var.name}_manage"})
}

resource "aws_default_network_acl" "default" {
  tags = merge(var.aws_build_tags, {Name = "${var.name}_default"})

  default_network_acl_id = var.default_network_acl_id

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