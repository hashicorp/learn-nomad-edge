module "primary-shared-resources" {
  source = "./shared-resources"

  region       = "us-east-2"
  vpc_azs      = ["us-east-2a", "us-east-2b", "us-east-2c"]
  name         = "learn-nomad-edge"
  whitelist_ip = "0.0.0.0/0"
}

module "edge-shared-resources" {
  source = "./shared-resources"

  region       = "us-west-1"
  vpc_azs      = ["us-west-1b", "us-west-1c"]
  name         = "learn-nomad-edge"
  whitelist_ip = "0.0.0.0/0"
}

module "primary-nomad-servers" {
  source = "./nomad-server"

  region   = "us-east-2"
  name     = "learn-nomad-edge"

  primary_security_group_id = module.primary-shared-resources.primary_security_group_id
  client_security_group_id  = module.primary-shared-resources.client_security_group_id
  public_subnets            = module.primary-shared-resources.public_subnets
  iam_instance_profile_name = module.primary-shared-resources.iam_instance_profile_name

  ami                  = "ami-0a32f737ac792a047"
  server_instance_type = "t2.micro"
  server_count         = "3"
}

module "primary-nomad-clients" {
  source = "./nomad-client"

  region   = "us-east-2"
  name     = "learn-nomad-edge"

  primary_security_group_id = module.primary-shared-resources.primary_security_group_id
  client_security_group_id  = module.primary-shared-resources.client_security_group_id
  public_subnets            = module.primary-shared-resources.public_subnets
  iam_instance_profile_name = module.primary-shared-resources.iam_instance_profile_name
  nomad_server_ips          = module.primary-nomad-servers.nomad_server_ips

  ami                  = "ami-0a32f737ac792a047"
  client_instance_type = "t2.small"
  client_count         = 1
  nomad_dc             = "dc1"
}

module "edge-nomad-clients" {
  source = "./nomad-client"

  region   = "us-west-1"
  name     = "learn-nomad-edge"

  primary_security_group_id = module.edge-shared-resources.primary_security_group_id
  client_security_group_id  = module.edge-shared-resources.client_security_group_id
  public_subnets            = module.edge-shared-resources.public_subnets
  iam_instance_profile_name = module.edge-shared-resources.iam_instance_profile_name
  nomad_server_ips          = module.primary-nomad-servers.nomad_server_ips

  ami                  = "ami-07d4b4348adb1fcc4"
  client_instance_type = "t2.small"
  client_count         = 1
  nomad_dc             = "dc2"
}

output "nomad-servers" {
  value = module.primary-nomad-servers.nomad_server_ips
}

output "nomad-server" {
  value = module.primary-nomad-servers.nomad_server_ips[0]
}

output "nomad_lb_address" {
  value = "http://${module.primary-nomad-servers.nomad_lb_address}:4646"
}

output "primary-dc-nomad-client" {
  value = module.primary-nomad-clients.nomad_client_ips[0]
}

output "edge-dc-nomad-client" {
  value = module.edge-nomad-clients.nomad_client_ips[0]
}