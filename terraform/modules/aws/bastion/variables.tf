variable "aws_build_tags" {
  type = map
}

variable name {
  description = "The name of the bastion host"
  type = string
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