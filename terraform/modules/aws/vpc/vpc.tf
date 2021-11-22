resource "aws_vpc" "golden" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.aws_build_tags, {Name = var.name})
}

resource "aws_internet_gateway" "public" {    
  vpc_id =  aws_vpc.golden.id               
  tags = merge(var.aws_build_tags, {Name = var.name})
}

resource "aws_default_network_acl" "default" {
  tags = merge(var.aws_build_tags, {Name = "${var.name}_default"})

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