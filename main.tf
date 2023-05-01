# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

module "primary_shared_resources" {
  source = "./shared-resources"

  region       = "us-east-2"
  vpc_azs      = ["us-east-2a", "us-east-2b", "us-east-2c"]
  name         = "learn-nomad-edge"
  whitelist_ip = "0.0.0.0/0"
}

module "edge_shared_resources" {
  source = "./shared-resources"

  region       = "us-west-1"
  vpc_azs      = ["us-west-1b", "us-west-1c"]
  name         = "learn-nomad-edge"
  whitelist_ip = "0.0.0.0/0"
}

module "primary_nomad_servers" {
  source = "./nomad-server"

  region = "us-east-2"
  name   = "learn-nomad-edge"

  server_security_group_id  = module.primary_shared_resources.server_security_group_id
  client_security_group_id  = module.primary_shared_resources.client_security_group_id
  public_subnets            = module.primary_shared_resources.public_subnets
  iam_instance_profile_name = module.primary_shared_resources.iam_instance_profile_name

  ami                  = var.primary_ami
  server_instance_type = "t2.micro"
  server_count         = 3
}

module "primary_nomad_clients" {
  source = "./nomad-client"

  region = "us-east-2"
  name   = "learn-nomad-edge"

  server_security_group_id  = module.primary_shared_resources.server_security_group_id
  client_security_group_id  = module.primary_shared_resources.client_security_group_id
  public_subnets            = module.primary_shared_resources.public_subnets
  iam_instance_profile_name = module.primary_shared_resources.iam_instance_profile_name
  nomad_server_ips          = module.primary_nomad_servers.nomad_server_ips

  ami                  = var.primary_ami
  client_instance_type = "t2.small"
  client_count         = 1
  nomad_dc             = "dc1"
}

module "edge_nomad_clients" {
  source = "./nomad-client"

  region = "us-west-1"
  name   = "learn-nomad-edge"

  server_security_group_id  = module.edge_shared_resources.server_security_group_id
  client_security_group_id  = module.edge_shared_resources.client_security_group_id
  public_subnets            = module.edge_shared_resources.public_subnets
  iam_instance_profile_name = module.edge_shared_resources.iam_instance_profile_name
  nomad_server_ips          = module.primary_nomad_servers.nomad_server_ips

  ami                  = var.edge_ami
  client_instance_type = "t2.small"
  client_count         = 2
  nomad_dc             = "dc2"
}