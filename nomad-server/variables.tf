variable "name" {
  description = "Used to name various infrastructure components"
  default     = "learn-nomad-edge"
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "ami" {
}

variable "server_instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t2.micro"
}

variable "root_block_device_size" {
  description = "The volume size of the root block device."
  default     = 16
}

variable "server_count" {
  description = "The number of servers to provision."
  default     = "3"
}

variable "retry_join" {
  description = "Used by Consul to automatically form a cluster."
  type        = map(string)

  default = {
    provider  = "aws"
    tag_key   = "ConsulAutoJoinNomadEdge"
    tag_value = "auto-join"
  }
}

variable "nomad_binary" {
  description = "Used to replace the machine image installed Nomad binary."
  default     = "none"
}

variable "server_security_group_id" {
  description = "Server security group ID"
}

variable "client_security_group_id" {
  description = "Client security group ID"
}

variable "public_subnets" {
  description = "Public subnets"
}

variable "iam_instance_profile_name" {
  description = "IAM Instance profile name"
}