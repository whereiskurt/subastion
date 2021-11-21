output "subastion_public_ip" {
  description = "subastion private key"
  value       = "${module.awsbastion.subastion_public_ip}"
}