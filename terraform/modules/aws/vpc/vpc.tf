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
