resource "null_resource" "makecert_vault" {
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

resource "local_file" "vault_key_file" {
  depends_on = [null_resource.makecert_vault]
  file_permission = 0400
  source  = var.openssl_env.VAULT_KEY_FILE
  filename = "../../docker/vault/volumes/config/vault.key.pem"
}

resource "local_file" "vault_cert_file" {
  depends_on = [null_resource.makecert_vault]
  file_permission = 0444
  source  = var.openssl_env.VAULT_CERT_FILE
  filename = "../../docker/vault/volumes/config/vault.cert.pem"
}

resource "local_file" "vault_config" {
  depends_on = [local_file.vault_cert_file, local_file.vault_key_file]
  file_permission = 0400
  content  = data.template_file.vault_conf.rendered
  filename = "../../docker/vault/volumes/config/vault.json"
}

resource "null_resource" "vault_start" {
  depends_on = [local_file.vault_config]
  provisioner "local-exec" {
    command = <<-EOT
      cd ../../docker/vault/ && docker-compose up -d && sleep 3
    EOT
  }
}

resource "null_resource" "vault_init" {
  depends_on = [null_resource.vault_start]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      vault operator init | \
        cut -d " " -f 4 | awk 'NF' | head --line -3  > $VAULT_SECRETS_FILE
    EOT
  }
}

resource "null_resource" "vault_login" {
  depends_on = [null_resource.vault_init]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      tail -n1 $VAULT_SECRETS_FILE | \
        vault login -
    EOT
  }
}