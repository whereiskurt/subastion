variable "aws_build_tags" {
  type = map
}

variable name {
  description = "The name of the NAT gateway"
  type = string
}

variable public_subnet_id {
  description = "The public subnet that has a Internet Gateway"
  type = string
}

variable private_route_table_id {
  description = "The id of the private routing table"
  type = string
}

variable manage_route_table_id {
  description = "The id fo the managed routing table"
  type = string
}
