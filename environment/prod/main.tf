module "openssl" {
  source = "../../terraform/modules/openssl"
  openssl_env= var.openssl_env
}

module "awsvault" {
  depends_on=[module.openssl]
  source = "../../terraform/modules/aws/vault"
  aws_build_tags = var.aws_build_tags
  aws_region = "${var.aws_region}"
  aws_kms_key_id = "${var.aws_kms_key_id}"
  aws_kms_key_alias = "${var.aws_kms_key_alias}"

  openssl_env= var.openssl_env

  vault_cert_dns_1 = "vault"
  vault_cert_dns_2="vault.golden.lab"
  vault_cert_dns_3="localhost"
  vault_cert_ip_1="172.16.1.102"
  vault_cert_ip_2="127.0.0.1"
}

##TODO: Add a concept of prefix like "blue/green/prod"
module "awsvpc" {
  source = "../../terraform/modules/aws/vpc"
  aws_build_tags = var.aws_build_tags
  vpc_cidr = "10.50.0.0/16"
}

module "awssubnet" {
  depends_on=[module.awsvpc]
  vpc_id="${awsvpc.vpc_id}"
  source = "../../terraform/modules/aws/subnet"
  aws_build_tags = var.aws_build_tags
  aws_availability_zone="ca-central-1a"
  public_subnets="10.50.0.0/20"
  manage_subnets = "10.50.16.0/20"
  private_subnets ="10.50.32.0/20"
}

##TODO: Add a concept of prefix like "blue/green/prod"
module "awsbastion" {
  depends_on=[module.awssubnet, module.awsvault]
  source = "../../terraform/modules/aws/bastion"
  
  aws_build_tags = var.aws_build_tags

  subastion_vpc_id = "${module.awsvpc.vpc_id}"

  public_subnet_id = "${module.awsvpc.public_subnet_id}"
  manage_subnet_id = "${module.awsvpc.manage_subnet_id}"
  private_subnet_id = "${module.awsvpc.private_subnet_id}"

  subastion_public_ip = "10.50.0.50"
  subastion_manage_ip = "10.50.16.50"
  subastion_private_ip = "10.50.32.50"
}