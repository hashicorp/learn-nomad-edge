# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
datacenter = "DATACENTER"

advertise {
  http = "IP_ADDRESS:4646"
  rpc  = "IP_ADDRESS:4647"
  serf = "IP_ADDRESS:4648"
}

# Enable the client
client {
  enabled = true
  options {
    "driver.raw_exec.enable"    = "1"
    "docker.privileged.enabled" = "true"
  }
  meta {
    node-name = "SERVER_NAME"
  }
  server_join {
    retry_join = [ RETRY_JOIN ]
    retry_max = 5
    retry_interval = "15s"
  }
  host_network "public" {
    cidr = "IP_ADDRESS/32"
  }
}

acl {
  enabled = true
}