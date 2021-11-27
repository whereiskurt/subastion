variable "aws_region" {
  type = string
  default = "ca-central-1"
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
    "builder" = "subastion-built"
    "auto_remove_by" = "20220601"
  }
}

variable "vault_env" {
  type = map
  default = {
    VAULT_ADDR = "https://127.0.0.1:8200"
    VAULT_SECRETS_FILE = "../../../docker/vault/vault.secrets.stripped"
    DOCKER_HOST_PORT=8200
    DOCKER_CONTAINER_PORT=8200
  }
}

variable "openssl_env" {
  type = map
  default = {
    DH_ENTROPY_FILE="../../../terraform/modules/openssl/dh.2048.pem"

    CA_CONF = "../../../terraform/modules/openssl/ca/ca.openssl.conf"
    CA_TPL = "../../../terraform/modules/openssl/ca/ca.openssl.tpl"
    CA_DIR = "../../../terraform/modules/openssl/ca/"
    
    ICA_CONF = "../../../terraform/modules/openssl/ica/ica.openssl.conf"
    ICA_TPL = "../../../terraform/modules/openssl/ica/ica.openssl.tpl"
    ICA_DIR= "../../../terraform/modules/openssl/ica/"
    
    VAULT_CONF = "../../../terraform/modules/openssl/vault/vault.openssl.conf"
    VAULT_TPL = "../../../terraform/modules/openssl/vault/vault.openssl.tpl"

    CA_KEY_FILE = "../../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../../terraform/modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../../terraform/modules/openssl/ica/ica.cert.pem"
    
    VAULT_KEY_FILE = "../../../terraform/modules/openssl/vault/vault.key.pem"
    VAULT_CSR_FILE = "../../../terraform/modules/openssl/vault/vault.csr.pem"
    VAULT_CERT_FILE = "../../../terraform/modules/openssl/vault/vault.cert.pem"

    CHAIN_PFX_FILE = "../../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/aws_bluegreen.ca.ica.pem"
  }
}