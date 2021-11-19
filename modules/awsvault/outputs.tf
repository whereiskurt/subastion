data "template_file" "vault_conf" {
  template = "${file("../../docker/vault/vault_config.tpl")}"
  vars = {  
    region        = "${var.aws_region}"
    access_key    = "${var.aws_access_key}"
    secret_key    = "${var.aws_secret_key}"
    kms_key_id    = "${var.aws_kms_key_id}"
    kms_key_alias = "${var.aws_kms_key_alias}"
  }
}

#access_key=${aws_iam_access_key.vault_user_access_key.id}
#secret_key=${aws_iam_access_key.vault_user_access_key.secret}

output "vault_config" {
  description = "JSON configuration file for vault"
  value       = data.template_file.vault_conf.rendered
  sensitive = true
}
