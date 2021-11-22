variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../terraform/modules/openssl/ca/ca.openssl.conf"
    ICA_CONF = "../../terraform/modules/openssl/ica/ica.openssl.conf"

    CA_KEY_FILE = "../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../terraform/modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../terraform/modules/openssl/ica/ica.cert.pem"
    
    CHAIN_PFX_FILE = "../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/golden.ca.ica.pem"
  }
}