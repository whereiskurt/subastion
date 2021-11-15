resource "null_resource" "makepfx_chain" {
  depends_on = [null_resource.makecert_ca, null_resource.makecert_ica]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      cat $CA_CERT_FILE $ICA_CERT_FILE | tee $CHAIN_CERT_FILE | \
       openssl pkcs12 -export -passout pass: -nokeys -in - \
         -out $CHAIN_PFX_FILE
    EOT
  }
}

resource "null_resource" "makecert_ca" {
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
        openssl genrsa -out $CA_KEY_FILE 4096 
    EOT
  }

  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
        openssl req -new -x509 -config $CA_CONF \
            -extensions v3_ca -days 7200 \
            -key $CA_KEY_FILE \
            -out $CA_CERT_FILE
    EOT
  }
}

resource "null_resource" "makecert_ica" {
  depends_on = [null_resource.makecert_ca]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl genrsa -out $ICA_KEY_FILE 4096 
    EOT
  }

  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl req -new -config $ICA_CONF \
        -key $ICA_KEY_FILE \
        -out $ICA_CSR_FILE
    EOT
  }

  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl ca -config $CA_CONF -extensions v3_intermediate_ca \
        -days 3650 -batch -notext \
        -in $ICA_CSR_FILE \
        -out $ICA_CERT_FILE
    EOT
  }

}