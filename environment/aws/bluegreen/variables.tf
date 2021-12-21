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

variable "aws_kms_key_alias" {
  type = string
  default = "orchestration"
}

variable "aws_kms_key_id" {
  type = string
  default = "edac385f-c393-4e9c-aab7-808e1bc3c899"
  sensitive = true
}

##Leaving this false prevents private/manage networks for getting out the Internet via outbound NAT.
variable build_nat_gateway {
  type = bool
  default = false
}

variable "vault_env" {
  type = map
  default = {
    VAULT_ADDR = "https://localhost:8200"
    VAULT_CACERT = "../../../terraform/modules/openssl/aws_bluegreen.ca.ica.pem"
    VAULT_SECRETS_FILE = "../../../terraform/modules/aws/vault/root.secret"
    DOCKER_HOST_PORT=8200
    DOCKER_CONTAINER_PORT=8200
  }
}

variable "aws_build_tags" {
  type = map
  default = {
    "builder" = "subastion-built"
    "auto_remove_by" = "20220601"
  }
}


variable "openssl_env" {
  type = map
  default = {
    DH_ENTROPY_FILE="../../../terraform/modules/openssl/dh.2048.pem"

    CA_CONF = "../../../terraform/modules/openssl/ca/ca.openssl.conf"
    CA_TPL = "../../../terraform/modules/openssl/ca/ca.openssl.tpl"
    CA_DIR = "../../../terraform/modules/openssl/ca/"
    CA_KEY_FILE = "../../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../../terraform/modules/openssl/ca/ca.cert.pem"
    
    ICA_CONF = "../../../terraform/modules/openssl/ica/ica.openssl.conf"
    ICA_TPL = "../../../terraform/modules/openssl/ica/ica.openssl.tpl"
    ICA_DIR= "../../../terraform/modules/openssl/ica/"
    ICA_KEY_FILE = "../../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../../terraform/modules/openssl/ica/ica.cert.pem"
    CHAIN_PFX_FILE = "../../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "../../../terraform/modules/openssl/aws_bluegreen.ca.ica.pem"
   
    VAULT_TPL = "../../../terraform/modules/aws/vault/vault.openssl.conf.tpl"
    VAULT_CONF = "../../../terraform/modules/aws/vault/vault.openssl.conf"
    VAULT_KEY_FILE = "../../../terraform/modules/aws/vault/vault.key.pem"
    VAULT_CSR_FILE = "../../../terraform/modules/aws/vault/vault.csr.pem"
    VAULT_CERT_FILE = "../../../terraform/modules/aws/vault/vault.cert.pem"
  }
}