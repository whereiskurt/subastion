module "vpc" {
  name="juice"
  source = "../../../terraform/modules/aws/vpc"
  aws_build_tags = var.aws_build_tags
  vpc_cidr = "10.51.0.0/16"
  openvpn_port = "11194"
}

## The NAT is attached to public network and provied a gateway to the manage/private networks
module "nat_juice" {
  count = var.build_nat_gateway ? 1 : 0
  depends_on=[module.subnet_juice]
  source = "../../../terraform/modules/aws/natgateway"
  aws_build_tags = var.aws_build_tags
  name="${module.vpc.name}"
  public_subnet_id=module.subnet_juice.public_subnet_id
  private_route_table_id=module.subnet_juice.private_route_table_id
  manage_route_table_id=module.subnet_juice.manage_route_table_id
}

module "subnet_juice" {
  depends_on=[module.vpc]
  source = "../../../terraform/modules/aws/subnet"
  name="${module.vpc.name}"
  aws_build_tags = var.aws_build_tags

  vpc_id=module.vpc.id
  internet_gateway_id=module.vpc.internet_gateway_id
  
  aws_availability_zone = var.aws_zones[0]
  public_subnets="10.51.0.0/20"
  manage_subnets = "10.51.16.0/20"
  private_subnets ="10.51.32.0/20"
}

data "aws_ami" "target_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

module "ec2_juiceshop" {
  depends_on=[module.subnet_juice]
  source = "../../../terraform/modules/aws/bastion"
  name="${module.vpc.name}_application"
  aws_build_tags = var.aws_build_tags
  
  zone_name="kurthundeck.com." ##NOTICE the '.' at the end!
  record_name="juice.kurthundeck.com"

  key_name="${module.vpc.name}_application_ec2"
  key_filename=pathexpand("~/.ssh/${module.vpc.name}_application_ec2")
  boot_template="juiceshop_boot.sh.tpl"
  instance_type = "t2.large"
  ami_id = data.aws_ami.target_ami.id
  security_groups=[module.vpc.subastion_security_group, module.vpc.http_security_group]
  
  subastion_vpc_id = module.vpc.id
  public_subnet_id = module.subnet_juice.public_subnet_id
  manage_subnet_id = module.subnet_juice.manage_subnet_id
  private_subnet_id = module.subnet_juice.private_subnet_id
  
  subastion_public_ip = "10.51.0.50"
  subastion_manage_ip = "10.51.16.50"
  subastion_private_ip = "10.51.32.50"

  vault_addr = var.vault_addr
  vault_cacert = var.vault_cacert

  openvpn_network = "10.51.48.0"
  openvpn_netmask = "255.255.255.240"
  openvpn_cidr = "10.51.48.0/20"
  openvpn_hostport = "11194"
}