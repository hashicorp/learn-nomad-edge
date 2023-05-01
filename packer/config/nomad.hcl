# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

advertise {
  http = "IP_ADDRESS:4646"
  rpc  = "IP_ADDRESS:4647"
  serf = "IP_ADDRESS:4648"
}

# Enable the server
server {
  enabled          = true
  bootstrap_expect = SERVER_COUNT

  server_join {
    retry_join = [ "RETRY_JOIN" ]
    retry_max = 3
    retry_interval = "15s"
  }
}

acl {
  enabled = true
}