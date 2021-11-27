data "template_file" "vault_conf" {
  template = "${file("../../../docker/vault/vault_config.tpl")}"
  vars = {  
    region        = "${var.aws_region}"
    access_key    = "${aws_iam_access_key.vault_root_access_key.id}"
    secret_key    = "${aws_iam_access_key.vault_root_access_key.secret}"
    kms_key_id    = "${var.aws_kms_key_id}"
    kms_key_alias = "${var.aws_kms_key_alias}"
    docker_container_port = "${var.docker_container_port}"
  }
}

data "template_file" "docker_compose_conf" {
  template = "${file("../../../docker/vault/docker-compose.yml.tpl")}"
  vars = {  
    docker_container_port = "${var.docker_container_port}"
    docker_host_port = "${var.docker_host_port}"
  }
}