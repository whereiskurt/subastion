output "juiceshop_public_ip" {
  description = "subastion green public internet address"
  value       = module.ec2_juiceshop.subastion_public_ip
}
