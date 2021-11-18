variable "aws_region" {
  type = string
  default = "ca-central-1"
}
variable "aws_access_key" {
  type = string
  sensitive = true
}
variable "aws_secret_key" {
  type = string
  sensitive = true
}
variable "aws_kms_key_alias" {
  type = string
}
variable "aws_kms_key_id" {
  type = string
  sensitive=true
}

variable "aws_build_tags" {
  type = map
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