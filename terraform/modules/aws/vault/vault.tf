resource "local_file" "openssl_vault_conf" {
  file_permission = 0400

  content = templatefile("${var.openssl_env.VAULT_TPL}", {
    vault_ica_folder=var.openssl_env.ICA_DIR
    vault_cert_dns=var.vault_cert_dns
    vault_cert_ip=var.vault_cert_ip
    vault_cert_country = var.vault_cert_country
    vault_cert_state = var.vault_cert_state 
    vault_cert_location = var.vault_cert_location 
    vault_cert_organization = var.vault_cert_organization 
    vault_cert_commonname = var.vault_cert_commonname
    vault_cert_nscomment =  var.vault_cert_nscomment 
  })

  filename = var.openssl_env.VAULT_CONF
}

resource "null_resource" "makecert_vault" {
  depends_on = [local_file.openssl_vault_conf]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl genrsa -out $VAULT_KEY_FILE 2048 
    EOT
  }
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl req -new -config $VAULT_CONF \
        -key $VAULT_KEY_FILE \
        -out $VAULT_CSR_FILE
    EOT
  }
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl ca -config $VAULT_CONF \
        -extensions server_cert \
        -batch -notext \
        -in $VAULT_CSR_FILE \
        -out $VAULT_CERT_FILE
    EOT
  }
}

resource "null_resource" "validate_certificates" {
  depends_on = [null_resource.makecert_vault]
  provisioner "local-exec" {
    environment = var.openssl_env
    command = <<-EOT
      openssl verify -verbose -CAfile $CA_CERT_FILE -untrusted $ICA_CERT_FILE $VAULT_CERT_FILE
    EOT
  }
}

resource "null_resource" "wait_for_iam" {
  depends_on = [aws_iam_access_key.vault_root_access_key]
  provisioner "local-exec" {
    command = "sleep 10"
  }
}

resource "local_file" "vault_config" {
  depends_on = [null_resource.makecert_vault]
  file_permission = 0400
  content  = data.template_file.vault_conf.rendered
  filename = "${path.module}/vault.json"
}

resource "local_file" "vault_systemd" {
  depends_on = [null_resource.makecert_vault]
  file_permission = 0400
  content  = data.template_file.vault_systemd.rendered
  filename = "${path.module}/vault.subastion.service"
}


resource "null_resource" "vault_start" {
  depends_on = [local_file.vault_config, local_file.vault_systemd, null_resource.wait_for_iam]
  provisioner "local-exec" {
    working_dir = "${path.module}"
    command = <<-EOT
    mkdir -p $HOME/.config/systemd/user/ && \
    cp vault.subastion.service $HOME/.config/systemd/user/ && \
    systemctl --user enable vault.subastion && \
    systemctl --user start vault.subastion
EOT
  }

  provisioner "local-exec" {
    when = destroy
    working_dir = "${path.module}"
    command = <<-EOT
    systemctl --user stop vault.subastion && \
    systemctl --user disable vault.subastion && \
    rm $HOME/.config/systemd/user/vault.subastion.service
EOT
  }
}

resource "null_resource" "wait_for_vault" {
  depends_on = [null_resource.vault_start]
  provisioner "local-exec" {
    command = "sleep 1"
  }
}

resource "null_resource" "vault_init" {
  depends_on = [null_resource.wait_for_vault]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      vault operator init | \
        cut -d " " -f 4 | awk 'NF' | head -n -3  > $VAULT_SECRETS_FILE
    EOT
  }
}

resource "null_resource" "vault_login" {
  depends_on = [null_resource.vault_init]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      tail -n1 $VAULT_SECRETS_FILE | \
        vault login - > /dev/null 2>&1
    EOT
  }
}
