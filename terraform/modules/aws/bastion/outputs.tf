output "subastion_public_ip" {
  description = "Intenert IP for the bastion host"
  value       = aws_eip.subastion.public_ip
}

data "template_file" "bastion_boot" {
  template = file(var.boot_template)
  vars = {
    name = var.name
    openvpn_network = var.openvpn_network
    openvpn_netmask = var.openvpn_netmask
    openvpn_server_name = aws_eip.subastion.public_ip
    openvpn_server_port= var.openvpn_hostport
    openvpn_cidr= var.openvpn_cidr
    
  }

}