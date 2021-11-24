variable "aws_region" {
  type = string
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

variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../terraform/modules/openssl/ca/ca.openssl.conf"
    ICA_CONF = "../../terraform/modules/openssl/ica/ica.openssl.conf"
    VAULT_CONF = "../../terraform/modules/openssl/vault/vault.openssl.conf"
    VAULT_TPL = "../../terraform/modules/openssl/vault/vault.openssl.tpl"

    CA_KEY_FILE = "../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../terraform/modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../terraform/modules/openssl/ica/ica.cert.pem"
    
    VAULT_KEY_FILE = "../../terraform/modules/openssl/vault/vault.key.pem"
    VAULT_CSR_FILE = "../../terraform/modules/openssl/vault/vault.csr.pem"
    VAULT_CERT_FILE = "../../terraform/modules/openssl/vault/vault.cert.pem"

    CHAIN_PFX_FILE = "../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/golden.ca.ica.pem"
  }
}


variable vault_cert_dns_1 {
  type = string
  default="vault"
}
variable vault_cert_dns_2 {
  type = string
  default="vault.golden.lab"
}
variable vault_cert_dns_3 {
  type = string
  default="localhost"
}

variable vault_cert_ip_1 {
  type = string
}
variable vault_cert_ip_2 {
  type = string
  default = "127.0.0.1"
}

variable "vault_env" {
  type = map
  default = {
    VAULT_ADDR = "https://127.0.0.1:8200"
    VAULT_SECRETS_FILE = "../../docker/vault/vault.secrets.stripped"
  }
}
