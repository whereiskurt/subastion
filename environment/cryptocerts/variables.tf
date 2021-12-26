variable "openssl_env" {
  type = map
  default = {
    DH_ENTROPY_FILE="../../terraform/modules/openssl/dh.2048.pem"

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
    
    CHAIN_PFX_FILE = "ca.ica.pfx"
    CHAIN_CERT_FILE = "ca.ica.pem"
  }
}