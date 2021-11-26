variable "openssl_env" {
  type = map
  default = {
    CA_CONF = "../../terraform/modules/openssl/ca/ca.openssl.conf"
    CA_TPL = "../../terraform/modules/openssl/ca/ca.openssl.tpl"
    CA_DIR = "../../terraform/modules/openssl/ca/"
    
    ICA_CONF = "../../terraform/modules/openssl/ica/ica.openssl.conf"
    ICA_TPL = "../../terraform/modules/openssl/ica/ica.openssl.tpl"
    ICA_DIR= "../../terraform/modules/openssl/ica/"

    CA_KEY_FILE = "../../terraform/modules/openssl/ca/ca.key.pem"    
    CA_CERT_FILE = "../../terraform/modules/openssl/ca/ca.cert.pem"

    ICA_KEY_FILE = "../../terraform/modules/openssl/ica/ica.key.pem"
    ICA_CSR_FILE = "../../terraform/modules/openssl/ica/ica.csr.pem"
    ICA_CERT_FILE = "../../terraform/modules/openssl/ica/ica.cert.pem"
    
    CHAIN_PFX_FILE = "../../terraform/modules/openssl/ca.ica.pfx"
    CHAIN_CERT_FILE = "/etc/ssl/certs/golden.ca.ica.pem"
  }
}

variable ica_cert_country {
  type=string
}
variable ica_cert_state {
  type=string
}
variable ica_cert_location {
  type=string
}
variable ica_cert_organization {
  type=string
}
variable ica_cert_commonname {
  type=string
}


variable ca_cert_country {
  type=string
}
variable ca_cert_state {
  type=string
}
variable ca_cert_location {
  type=string
}
variable ca_cert_organization {
  type=string
}
variable ca_cert_commonname {
  type=string
}