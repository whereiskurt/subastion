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

  ##Note: After terraform apply the aws_deafult_network_acl will have changed
  ## with additional subnets affectd by the default
  lifecycle {
    ignore_changes = [subnet_ids]
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  
  ingress {
    protocol   = "tcp"
    rule_no    = 111
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "udp"
    rule_no    = 122
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.openvpn_port
    to_port    = var.openvpn_port
  }

  ##These emphemereal ports are necessary to allow TCP (ie. apt upgrade) to succeed. for EGRESS.
  ##Running `sysctl -A | grep ip_local_port_range` reveals ephemereal ports
  ingress {
    protocol   = "tcp"
    rule_no    = 133
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 60999
  }

  egress {
    protocol   = "tcp"
    rule_no    = 201
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }
  egress {
    protocol   = "tcp"
    rule_no    = 212
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ##These ephemereal ports allow EC2 instances have successful INGRES TCP connections
  egress {
    protocol   = "tcp"
    rule_no    = 223
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 60999
  }

  egress {
    protocol   = "udp"
    rule_no    = 234
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 53
    to_port    = 53
  }
  egress {
    protocol   = "udp"
    rule_no    = 245
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = var.openvpn_port
    to_port    = var.openvpn_port
  } 

  ##TODO: Figure out why this outbound rule is needed to support openvpn
  egress {
    protocol   = "udp"
    rule_no    = 246
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  } 

}