# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "nomad_client_ips" {
  value = aws_instance.client.*.public_ip
}

output "nomad_server_ips" {
  value = var.nomad_server_ips
}