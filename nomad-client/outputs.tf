output "nomad_client_ips" {
  value = aws_instance.client.*.public_ip
}