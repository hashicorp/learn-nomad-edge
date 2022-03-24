data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"
datacenter = "DATACENTER"

# Enable the client
client {
  enabled = true
  options {
    "driver.raw_exec.enable"    = "1"
    "docker.privileged.enabled" = "true"
  }
  meta {
    node-name = "SERVER_NAME"
    service-client = "SERVICE_CLIENT"
  }
  servers = [ RETRY_JOIN ]
}

acl {
  enabled = true
}