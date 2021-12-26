module "openssl" {
  source = "../../terraform/modules/openssl"
  openssl_env= var.openssl_env

  ##Self-signed Certificate Authority 
  ca_cert_commonname="Private Company (CA)"
  ca_cert_organization="Private Company"
  ca_cert_location="Toronto"
  ca_cert_state="ON"
  ca_cert_country="CA"

  ##Intermediary-Certifiated Authority signed by CA (ie. self signed)
  ica_cert_commonname="Private Company (ICA)"
  ica_cert_organization="Private Company"
  ica_cert_location="Toronto"
  ica_cert_state="ON"
  ica_cert_country="CA"
}

resource "null_resource" "move_certs_to_vault" {
  depends_on = [module.openssl]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      cp -pr ${path.cwd}/terraform/modules/openssl/$CHAIN_CERT_FILE ${path.cwd}/docker/ && \
      cp -pr ${path.cwd}/terraform/modules/openssl/$CHAIN_PFX_FILE ${path.cwd}/docker/
EOT
  }
}