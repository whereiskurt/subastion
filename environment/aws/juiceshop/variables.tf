variable "aws_region" {
  type = string
  default = "ca-central-1"
}

variable "aws_zones" {
  type = list(string)
  default = ["ca-central-1a", "ca-central-1b"]
}

variable "aws_profile" {
  type = string
  default = "default"
}

variable vault_addr {
  type=string
  default = "https://localhost:8200"
}
variable vault_cacert {
  type = string
  default = "../../../terraform/modules/openssl/ca.ica.pem"
}

##Leaving this false prevents private/manage networks for getting out the Internet via outbound NAT.
variable build_nat_gateway {
  type = bool
  default = false
}

variable "aws_build_tags" {
  type = map
  default = {
    "builder" = "subastion-built"
    "auto_remove_by" = "20220601"
  }
}
