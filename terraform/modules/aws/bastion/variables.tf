variable "instance_type" {
  description = "The EC2 instance type to create - defaults to small"
  default="t2.small"
  type = string
}

variable "ami_id" {
  description = "This is the reference to "
  default = "" ## This will ensure data.aws_ami.ubuntu.id
  type = string
}

variable "aws_build_tags" {
  type = map
}

variable name {
  description = "The name of the bastion host"
  type = string
}

variable zone_name {
  description = "Name of DNS zone"
  type = string
}
variable record_name {
  description = "The name to put into the A record"
  type = string
}

variable vault_addr {
  type=string
}
variable vault_cacert {
  type=string
}

variable openvpn_network {
  type=string
}
variable openvpn_netmask {
  type=string
}
variable openvpn_cidr {
  type=string
}

variable openvpn_hostport {
  type=string
}

variable boot_template {
  type=string
}

variable "key_name" {
  type = string
}
variable "key_filename" {
  type = string
}

variable security_groups {
  type=list(string)
}

variable "public_subnet_id" {
  type = string
}

variable "private_subnet_id" {
  type = string
}

variable "manage_subnet_id" {
  type = string
}
variable "subastion_public_ip" {
  type = string
}

variable "subastion_private_ip" {
  type = string
}
variable "subastion_manage_ip" {
  type = string
}

variable "subastion_vpc_id" {
  type = string
}