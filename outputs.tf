# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "nomad_servers" {
  value = module.primary_nomad_servers.nomad_server_ips
}

output "nomad_server" {
  value = module.primary_nomad_servers.nomad_server_ips[0]
}

output "nomad_server_1" {
  value = module.primary_nomad_servers.nomad_server_ips[1]
}

output "nomad_server_2" {
  value = module.primary_nomad_servers.nomad_server_ips[2]
}

output "nomad_lb_address" {
  value = "http://${module.primary_nomad_servers.nomad_lb_address}:4646"
}

output "nomad_primary_dc_clients" {
  value = module.primary_nomad_clients.nomad_client_ips
}

output "primary_dc_nomad_client" {
  value = module.primary_nomad_clients.nomad_client_ips[0]
}

output "edge_dc_nomad_client" {
  value = module.edge_nomad_clients.nomad_client_ips[0]
}