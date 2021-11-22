module "openssl" {
  source = "../../terraform/modules/openssl"
  openssl_env= var.openssl_env
}

module "awsvault" {
  depends_on=[module.openssl]
  source = "../../terraform/modules/aws/vault"
  aws_build_tags = var.aws_build_tags
  aws_region = var.aws_region
  aws_kms_key_id = var.aws_kms_key_id
  aws_kms_key_alias = var.aws_kms_key_alias

  openssl_env= var.openssl_env

  ##TODO: Add an actual data provider that renders the templates
  vault_cert_dns_1 = "vault"
  vault_cert_dns_2="vault.golden.lab"
  vault_cert_dns_3="localhost"
  vault_cert_ip_1="172.16.1.102"
  vault_cert_ip_2="127.0.0.1"
}

module "awsvpc" {
  name="prod"
  source = "../../terraform/modules/aws/vpc"
  aws_build_tags = var.aws_build_tags
  vpc_cidr = "10.50.0.0/16"
}

module "subnet_green" {
  depends_on=[module.awsvpc]
  source = "../../terraform/modules/aws/subnet"
  name="prod_green"
  aws_build_tags = var.aws_build_tags

  vpc_id=module.awsvpc.vpc_id
  internet_gateway_id=module.awsvpc.internet_gateway_id
  
  aws_availability_zone="ca-central-1a"
  public_subnets="10.50.0.0/20"
  manage_subnets = "10.50.16.0/20"
  private_subnets ="10.50.32.0/20"
}

module "nat_green" {
  depends_on=[module.subnet_green]
  source = "../../terraform/modules/aws/natgateway"
  aws_build_tags = var.aws_build_tags
  name="prod_green"
  public_subnet_id=module.subnet_green.public_subnet_id
  private_route_table_id=module.subnet_green.private_route_table_id
  manage_route_table_id=module.subnet_green.manage_route_table_id
}

module "ec2_bastion_green" {
  depends_on=[module.subnet_green, module.awsvault]
  source = "../../terraform/modules/aws/bastion"
  name="prod_green_subastion"
  aws_build_tags = var.aws_build_tags
  key_name="prod_green_subastion_ec2"
  subastion_vpc_id = module.awsvpc.vpc_id
  
  security_groups=[module.awsvpc.subastion_security_group]

  public_subnet_id = module.subnet_green.public_subnet_id
  manage_subnet_id = module.subnet_green.manage_subnet_id
  private_subnet_id = module.subnet_green.private_subnet_id

  subastion_public_ip = "10.50.0.50"
  subastion_manage_ip = "10.50.16.50"
  subastion_private_ip = "10.50.32.50"
}

module "subnet_blue" {
  depends_on=[module.awsvpc]
  source = "../../terraform/modules/aws/subnet"
  name="prod_blue"
  aws_build_tags = var.aws_build_tags

  vpc_id=module.awsvpc.vpc_id
  internet_gateway_id=module.awsvpc.internet_gateway_id
  
  aws_availability_zone="ca-central-1b"
  public_subnets="10.50.64.0/20"
  manage_subnets = "10.50.80.0/20"
  private_subnets ="10.50.96.0/20"
}

module "ec2_bastion_blue" {
  depends_on=[module.subnet_blue, module.awsvault]
  source = "../../terraform/modules/aws/bastion"
  name="prod_blue_subastion"
  aws_build_tags = var.aws_build_tags
  key_name="prod_blue_subastion_ec2"
  subastion_vpc_id = module.awsvpc.vpc_id

  security_groups=[module.awsvpc.subastion_security_group]

  public_subnet_id = module.subnet_blue.public_subnet_id
  manage_subnet_id = module.subnet_blue.manage_subnet_id
  private_subnet_id = module.subnet_blue.private_subnet_id

  subastion_public_ip = "10.50.64.50"
  subastion_manage_ip = "10.50.80.50"
  subastion_private_ip = "10.50.96.50"
}