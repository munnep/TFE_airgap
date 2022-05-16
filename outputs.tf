output "ssh_server" {
    value = "ssh ubuntu@${aws_eip.tfe-eip.public_ip}"
}

output "tfe_dashboard" {
    value = "https://${var.dns_hostname}.${var.dns_zonename}:8800"
}

output "tfe_appplication" {
    value = "https://${var.dns_hostname}.${var.dns_zonename}"
}
