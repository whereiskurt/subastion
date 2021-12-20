data "template_file" "vault_conf" {
  template = file("${path.module}/vault_config.tpl")
  vars = {  
    region        = var.aws_region
    access_key    = aws_iam_access_key.vault_root_access_key.id
    secret_key    = aws_iam_access_key.vault_root_access_key.secret
    kms_key_id    = var.aws_kms_key_id
    kms_key_alias = var.aws_kms_key_alias
    docker_container_port = var.vault_env.DOCKER_CONTAINER_PORT
  }
}

data "template_file" "vault_systemd" {
  template = file("${path.module}/vault.subastion.service.tpl")
  vars = {  
    working_dir   = abspath(path.module)
  }
}