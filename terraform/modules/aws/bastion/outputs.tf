output "subastion_public_ip" {
  description = "Intenert IP for the bastion host"
  value       = "${aws_eip.subastion.public_ip}"
}

data "template_file" "bastion_boot" {
  template = "${file(var.boot_template)}"

  vars = {
    name = "${var.name}"
  }
}