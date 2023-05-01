# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "server_security_group_id" {
  value = aws_security_group.server_lb.id
}

output "client_security_group_id" {
  value = aws_security_group.client_sg.id
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.instance_profile.name
}