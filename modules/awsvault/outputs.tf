data "template_file" "vault_conf" {
  template = "${file("../../docker/vault/vault_config.tpl")}"
  vars = {  
    region        = "${var.aws_region}"
    access_key    = "${aws_iam_access_key.vault_root_access_key.id}"
    secret_key    = "${aws_iam_access_key.vault_root_access_key.secret}"
    kms_key_id    = "${var.aws_kms_key_id}"
    kms_key_alias = "${var.aws_kms_key_alias}"
  }
}

output "vault_config" {
  description = "JSON configuration file for vault"
  value       = data.template_file.vault_conf.rendered
  sensitive = true
}
