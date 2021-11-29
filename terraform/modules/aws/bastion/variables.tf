variable "aws_build_tags" {
  type = map
}

variable name {
  description = "The name of the bastion host"
  type = string
}

variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../../../terraform/modules/openssl/ca/ca.openssl.conf"
    CA_TPL = "../../../../terraform/modules/openssl/ca/ca.openssl.tpl"
    CA_DIR = "../../../../terraform/modules/openssl/ca/"
    CA_KEY_FILE = "../../../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../../../terraform/modules/openssl/ca/ca.cert.pem"
    
    ICA_CONF = "../../../../terraform/modules/openssl/ica/ica.openssl.conf"
    ICA_TPL = "../../../../terraform/modules/openssl/ica/ica.openssl.tpl"
    ICA_DIR= "../../../../terraform/modules/openssl/ica/"
    ICA_KEY_FILE = "../../../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../../../terraform/modules/openssl/ica/ica.cert.pem"
    CHAIN_PFX_FILE = "../../../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/aws_bluegreen.ca.ica.pem"
  }
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