module "openssl" {
  source = "../../modules/openssl"
  aws_config = var.aws_config
  aws_build_tags = var.aws_build_tags
  openssl_env= var.openssl_env
}

module "vault" {
  depends_on=[module.openssl]
  source = "../../modules/vault"
  aws_config = var.aws_config
  aws_build_tags = var.aws_build_tags
  openssl_env= var.openssl_env

  vault_cert_dns_1 = "vault"
  vault_cert_dns_2="vault.golden.lab"
  vault_cert_dns_3="localhost"
  
  vault_cert_ip_1="172.16.1.102"
  vault_cert_ip_2="127.0.0.1"
}

##TODO: Add a concept of prefix like "blue/green/prod"
module "awsvpc" {
  source = "../../modules/awsvpc"
  aws_config = var.aws_config
  aws_build_tags = var.aws_build_tags

  vpc_cidr = "10.50.0.0/16"

  public_subnets= "10.50.0.0/20"
  manage_subnets = "10.50.16.0/20"
  private_subnets ="10.50.32.0/20"
}

##TODO: Add a concept of prefix like "blue/green/prod"
module "awsbastion" {
  depends_on=[module.awsvpc, module.vault]
  source = "../../modules/awsbastion"
  aws_config = var.aws_config
  aws_build_tags = var.aws_build_tags

  subastion_vpc_id = "${module.awsvpc.vpc_id}"

  public_subnet_id = "${module.awsvpc.public_subnet_id}"
  manage_subnet_id = "${module.awsvpc.manage_subnet_id}"
  private_subnet_id = "${module.awsvpc.private_subnet_id}"

  subastion_public_ip = "10.50.0.50"
  subastion_manage_ip = "10.50.16.50"
  subastion_private_ip = "10.50.32.50"
}