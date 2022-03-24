output "nomad_client_ips" {
  value = aws_instance.client.*.public_ip
}

output "nomad_server_ips" {
  value = var.nomad_server_ips
}