variable "aws_config" {
  type = map
}

variable "aws_build_tags" {
  type = map
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
