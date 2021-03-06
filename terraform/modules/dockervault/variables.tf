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
    CA_TPL = "../../terraform/modules/openssl/ca/ca.openssl.tpl"
    CA_DIR = "../../terraform/modules/openssl/ca/"
    CA_KEY_FILE = "../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../terraform/modules/openssl/ca/ca.cert.pem"
    
    ICA_CONF = "../../terraform/modules/openssl/ica/ica.openssl.conf"
    ICA_TPL = "../../terraform/modules/openssl/ica/ica.openssl.tpl"
    ICA_DIR= "../../terraform/modules/openssl/ica/"
    ICA_KEY_FILE = "../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../terraform/modules/openssl/ica/ica.cert.pem"
    
    VAULT_TPL = "../../terraform/modules/dockervault/vault.openssl.conf.tpl"
    VAULT_CONF = "../../terraform/modules/dockervault/vault.openssl.conf"
    VAULT_KEY_FILE = "../../terraform/modules/dockervault/vault.key.pem"
    VAULT_CSR_FILE = "../../terraform/modules/dockervault/vault.csr.pem"
    VAULT_CERT_FILE = "../../terraform/modules/dockervault/vault.cert.pem"

    CHAIN_PFX_FILE = "../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "../../terraform/modules/openssl/ca.ica.pem"
  }
}

variable boot_template {
  type = string
  default="../../terraform/modules/aws/bastion/bastion_boot.sh.tpl"
}

variable vault_cert_dns {
  type = list(string)
}

variable vault_cert_ip {
  type = list(string)
}

variable vault_cert_country {
  type=string
}
variable vault_cert_state {
  type=string
}
variable vault_cert_location {
  type =string
}
variable vault_cert_organization {
  type=string
}
variable vault_cert_nscomment {
  type=string
} 
variable vault_cert_commonname {
  type=string
} 
variable "vault_env" {
  type = map
  default = {
    VAULT_ADDR = "https://localhost:18200"
    VAULT_SECRETS_FILE = "../../docker/vault/root.secret"
    DOCKER_HOST_PORT=8200
    DOCKER_CONTAINER_PORT=18200
  }
}
