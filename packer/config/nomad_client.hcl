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
  server_join {
    retry_join = [ RETRY_JOIN ]
    retry_max = 5
    retry_interval = "15s"
  }
}

acl {
  enabled = true
}