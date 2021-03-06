resource "null_resource" "makepfx_chain" {
  depends_on = [null_resource.makecert_ca, null_resource.makecert_ica]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      cat $CA_CERT_FILE $ICA_CERT_FILE | tee ${path.module}/$CHAIN_CERT_FILE | \
       openssl pkcs12 -export -passout pass: -nokeys -in - \
         -out ${path.module}/$CHAIN_PFX_FILE
    EOT
  }
}

resource "local_file" "openssl_ca_conf" {
  file_permission = 0400

  content = templatefile(var.openssl_env.CA_TPL, {
    ca_folder=var.openssl_env.CA_DIR
    ca_cert_country = var.ca_cert_country
    ca_cert_state = var.ca_cert_state 
    ca_cert_location = var.ca_cert_location 
    ca_cert_organization = var.ca_cert_organization
    ca_cert_commonname =  var.ca_cert_commonname
  })

  filename = var.openssl_env.CA_CONF
}

resource "null_resource" "makecert_ca" {
  depends_on = [local_file.openssl_ca_conf]
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

resource "null_resource" "make_dh2048" {
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      [[ -f $DH_ENTROPY_FILE ]] || openssl dhparam -out $DH_ENTROPY_FILE 2048
    EOT
  }
}

resource "local_file" "openssl_ica_conf" {
  file_permission = 0400

  content = templatefile("${var.openssl_env.ICA_TPL}", {
    ica_folder=var.openssl_env.ICA_DIR
    ica_cert_country = var.ica_cert_country
    ica_cert_state = var.ica_cert_state 
    ica_cert_location = var.ica_cert_location 
    ica_cert_organization = var.ica_cert_organization
    ica_cert_commonname =  var.ica_cert_commonname
  })

  filename = var.openssl_env.ICA_CONF
}

resource "null_resource" "makecert_ica" {
  depends_on = [null_resource.makecert_ca, local_file.openssl_ica_conf]
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