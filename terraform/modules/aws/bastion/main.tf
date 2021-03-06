resource "tls_private_key" "subastion" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "subastion_key" {
  key_name   = var.key_name
  public_key = tls_private_key.subastion.public_key_openssh
  tags = var.aws_build_tags
}

###TODO: Move login and secrets enable to vault
resource "null_resource" "vault_subastion_key" {
  depends_on = [ aws_key_pair.subastion_key ]

  provisioner "local-exec" {
    command = <<-EOT
      VAULT_ADDR=${var.vault_addr} \
      VAULT_CACERT=${var.vault_cacert} \
      VAULT_TOKEN=`cat ${path.cwd}/environment/dockervault/vaultadmin.token` \
      vault kv put subastion/${var.key_name} \
        ip=${aws_eip.subastion.public_ip} \
        pem=${base64encode(tls_private_key.subastion.private_key_pem)} 
    EOT
  }
}

resource "local_file" "bastion_key_pem" {
  depends_on = [aws_key_pair.subastion_key]
  file_permission = 0400
  content  = tls_private_key.subastion.private_key_pem
  filename = var.key_filename
}

data "aws_ami" "ubuntu" {
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

resource "aws_network_interface" "subastion_public" {
  subnet_id   = var.public_subnet_id
  private_ips = [var.subastion_public_ip]
  tags = merge(var.aws_build_tags, {Name = "${var.name}_public"})
  security_groups = var.security_groups
}

resource "aws_network_interface" "subastion_private" {
  subnet_id   = var.private_subnet_id
  private_ips = [var.subastion_private_ip]
  tags = merge(var.aws_build_tags, {Name = "${var.name}_private"})
}

resource "aws_network_interface" "subastion_manage" {
  subnet_id   = var.manage_subnet_id
  private_ips = [var.subastion_manage_ip]
  tags = merge(var.aws_build_tags, {Name = "${var.name}_manage"})
}
resource "aws_eip" "subastion" {
  vpc                       = true
  network_interface         = aws_network_interface.subastion_public.id
  associate_with_private_ip = var.subastion_public_ip
  tags = merge(var.aws_build_tags, {Name = var.name})
}

resource "aws_instance" "subastion" {
  ami           = var.ami_id == "" ? data.aws_ami.ubuntu.id : var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.subastion_key.key_name
 
  tags = merge(var.aws_build_tags, {Name = var.name})

  user_data = data.template_file.bastion_boot.rendered

  network_interface {
    network_interface_id = aws_network_interface.subastion_public.id
    device_index         = 0
  } 
  network_interface {
    network_interface_id = aws_network_interface.subastion_manage.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.subastion_private.id
    device_index         = 2
  } 
}

## The 'zone_name' is looked-up.
data "aws_route53_zone" "zone" {
  count = var.zone_name == "" ? 0 : 1
  name         = var.zone_name
  private_zone = false
}

resource "aws_route53_record" "record" {
  count = var.record_name == "" ? 0 : 1
  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = var.record_name
  type    = "A"
  ttl     = "60"
  records = [aws_eip.subastion.public_ip]
}