output "subastion_public_ip" {
  description = "Intenert IP for the bastion host"
  value       = "${aws_eip.subastion.public_ip}"
}