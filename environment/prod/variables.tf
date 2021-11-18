variable "aws_region" {
  type = string
  default = "ca-central-1"
}
variable "aws_access_key" {
  type = string
  default = "AKIAXAKHUY4U4F4A7O5N"
  sensitive = true
}
variable "aws_secret_key" {
  type = string
  default = "4AbhYLGQRZsrlNO05aYkFw5etL/mMXpxVlhdAUgF"
  sensitive = true
}
variable "aws_kms_key_alias" {
  type = string
  default = "orchestration"
}
variable "aws_kms_key_id" {
  type = string
  default = "edac385f-c393-4e9c-aab7-808e1bc3c899"
  sensitive = true
}

variable "aws_build_tags" {
  type = map
  default = {
    "owner" = "KPH"
    "review_by" = "20221025"
  }
}

variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../modules/openssl/ca/ca.openssl.conf"
    ICA_CONF = "../../modules/openssl/ica/ica.openssl.conf"
    VAULT_CONF = "../../modules/openssl/vault/vault.openssl.conf"

    CA_KEY_FILE = "../../modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../modules/openssl/ica/ica.cert.pem"
    
    VAULT_KEY_FILE = "../../modules/openssl/vault/vault.key.pem"
    VAULT_CSR_FILE = "../../modules/openssl/vault/vault.csr.pem"
    VAULT_CERT_FILE = "../../modules/openssl/vault/vault.cert.pem"

    CHAIN_PFX_FILE = "../../modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/golden.ca.ica.pem"
  }
}