output "nomad_lb_address" {
  value = aws_elb.server_lb.dns_name
}

output "nomad_server_ips" {
  value = aws_instance.server.*.public_ip
}