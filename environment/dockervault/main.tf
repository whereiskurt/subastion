module "awsvault" {
  source = "../../terraform/modules/dockervault"
  aws_build_tags = var.aws_build_tags
  aws_region = var.aws_region
  aws_kms_key_id = var.aws_kms_key_id
  aws_kms_key_alias = var.aws_kms_key_alias

  ##CA/ICA certificates/keys for signing vault certs
  openssl_env=var.openssl_env
  vault_env = var.vault_env

  vault_cert_nscomment = "Private Company - Vault Certificate"
  vault_cert_organization = "Private Company"
  vault_cert_location = "Toronto"
  vault_cert_state = "ON"
  vault_cert_country = "CA"
  vault_cert_commonname = "Private Company (CommonName)"
  vault_cert_dns = ["localhost","vault","vaultsubastion"]
  vault_cert_ip = ["127.0.0.1", "192.168.1.229"]
}
resource "null_resource" "move_vault_pem_to_docker" {
  depends_on = [module.awsvault]
  provisioner "local-exec" {
    environment = var.vault_env
    command = <<-EOT
      cp -pr ${path.cwd}/environment/dockervault/vaultadmin.token ${path.cwd}/docker/ && \
      cp -pr ${path.cwd}/terraform/modules/dockervault/vault.cert.pem ${path.cwd}/docker/
EOT
  }
}