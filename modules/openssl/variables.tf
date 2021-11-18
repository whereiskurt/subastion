variable "aws_build_tags" {
  type = map
}

# variable "aws_config" {
#   type = map
# }

variable "aws_region" {
  type = string
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

variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../modules/openssl/ca/ca.openssl.conf"
    ICA_CONF = "../../modules/openssl/ica/ica.openssl.conf"

    CA_KEY_FILE = "../../modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../modules/openssl/ica/ica.cert.pem"
    
    CHAIN_PFX_FILE = "../../modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/golden.ca.ica.pem"
  }
}