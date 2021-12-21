module "vpc" {
  name="prod"
  source = "../../../terraform/modules/aws/vpc"
  aws_build_tags = var.aws_build_tags
  vpc_cidr = "10.50.0.0/16"
  openvpn_port = "11194"
}

module "nat_green" {
  count = var.build_nat_gateway ? 1 : 0
  depends_on=[module.subnet_green]
  source = "../../../terraform/modules/aws/natgateway"
  aws_build_tags = var.aws_build_tags
  name="${module.vpc.name}_green"
  public_subnet_id=module.subnet_green.public_subnet_id
  private_route_table_id=module.subnet_green.private_route_table_id
  manage_route_table_id=module.subnet_green.manage_route_table_id
}

module "subnet_green" {
  depends_on=[module.vpc]
  source = "../../../terraform/modules/aws/subnet"
  name="${module.vpc.name}_green"
  aws_build_tags = var.aws_build_tags

  vpc_id=module.vpc.id
  internet_gateway_id=module.vpc.internet_gateway_id
  
  aws_availability_zone = var.aws_zones[0]
  public_subnets="10.50.0.0/20"
  manage_subnets = "10.50.16.0/20"
  private_subnets ="10.50.32.0/20"
}

module "ec2_subastion_green" {
  depends_on=[module.subnet_green]
  source = "../../../terraform/modules/aws/bastion"
  name="${module.vpc.name}_green_subastion"
  aws_build_tags = var.aws_build_tags
  
  key_name="${module.vpc.name}_green_subastion_ec2"
  key_filename=pathexpand("~/.ssh/${module.vpc.name}_green_subastion_ec2")
  boot_template="../../../terraform/modules/aws/bastion/bastion_boot.sh.tpl"
  
  security_groups=[module.vpc.subastion_security_group]
  
  subastion_vpc_id = module.vpc.id
  public_subnet_id = module.subnet_green.public_subnet_id
  manage_subnet_id = module.subnet_green.manage_subnet_id
  private_subnet_id = module.subnet_green.private_subnet_id
  
  subastion_public_ip = "10.50.0.50"
  subastion_manage_ip = "10.50.16.50"
  subastion_private_ip = "10.50.32.50"

  openssl_env= var.openssl_env
  vault_env = var.vault_env

  openvpn_network = "10.50.48.0"
  openvpn_netmask = "255.255.255.240"
  openvpn_cidr = "10.50.48.0/20"
  openvpn_hostport = "11194"
}

module "nat_blue" {
  count = var.build_nat_gateway ? 1 : 0
  depends_on=[module.subnet_blue]
  source = "../../../terraform/modules/aws/natgateway"
  aws_build_tags = var.aws_build_tags
  name="${module.vpc.name}_blue"
  public_subnet_id=module.subnet_blue.public_subnet_id
  private_route_table_id=module.subnet_blue.private_route_table_id
  manage_route_table_id=module.subnet_blue.manage_route_table_id
}

module "subnet_blue" {
  depends_on=[module.vpc]
  source = "../../../terraform/modules/aws/subnet"
  name="${module.vpc.name}_blue"
  aws_build_tags = var.aws_build_tags

  vpc_id=module.vpc.id
  internet_gateway_id=module.vpc.internet_gateway_id
  
  aws_availability_zone=var.aws_zones[1]
  public_subnets="10.50.64.0/20"
  manage_subnets = "10.50.80.0/20"
  private_subnets ="10.50.96.0/20"
}

module "ec2_subastion_blue" {
  depends_on=[module.subnet_blue]
  source = "../../../terraform/modules/aws/bastion"
  name="${module.vpc.name}_blue_subastion"
  aws_build_tags = var.aws_build_tags

  key_name="${module.vpc.name}_blue_subastion_ec2"
  key_filename=pathexpand("~/.ssh/${module.vpc.name}_blue_subastion_ec2")
  boot_template="../../../terraform/modules/aws/bastion/bastion_boot.sh.tpl"

  openssl_env= var.openssl_env
  vault_env = var.vault_env

  subastion_vpc_id = module.vpc.id
  security_groups=[module.vpc.subastion_security_group]
  public_subnet_id = module.subnet_blue.public_subnet_id
  manage_subnet_id = module.subnet_blue.manage_subnet_id
  private_subnet_id = module.subnet_blue.private_subnet_id
  subastion_public_ip = "10.50.64.50"
  subastion_manage_ip = "10.50.80.50"
  subastion_private_ip = "10.50.96.50"

  openvpn_network = "10.50.112.0"
  openvpn_cidr = "10.50.112.0/20"
  openvpn_netmask = "255.255.255.240"
  openvpn_hostport = "11194"
}