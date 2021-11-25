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

data "template_file" "openssl_vault_conf" {
  template = "${file(var.openssl_env.VAULT_TPL)}"
  vars = {  
    vault_cert_dns_1=var.vault_cert_dns_1
    vault_cert_dns_2=var.vault_cert_dns_2
    vault_cert_dns_3=var.vault_cert_dns_3
    vault_cert_ip_1=var.vault_cert_ip_1
    vault_cert_ip_2=var.vault_cert_ip_2
    vault_cert_country = var.vault_cert_country
    vault_cert_state = var.vault_cert_state 
    vault_cert_location = var.vault_cert_location 
    vault_cert_oganization = var.vault_cert_oganization 
    vault_cert_nscomment =  var.vault_cert_nscomment 
  }
}
