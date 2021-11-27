output "subastion_green_public_ip" {
  description = "subastion green public internet address"
  value       = module.ec2_subastion_green.subastion_public_ip
}

output "subastion_blue_public_ip" {
  description = "subastion blue public internet address"
  value       = module.ec2_subastion_blue.subastion_public_ip
}