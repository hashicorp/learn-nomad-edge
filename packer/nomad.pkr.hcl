variable "name" {
  type    = string
  default = "learn-nomad-edge-tu"
}

variable "region-primary" {
  type    = string
  default = "us-east-2"
}

variable "region-secondary" {
  type    = string
  default = "us-west-1"
}

data "amazon-ami" "ubuntu-primary" {
  region = var.region-primary
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

data "amazon-ami" "ubuntu-secondary" {
  region = var.region-secondary
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

locals { timestamp = regex_replace(timestamp(), "[- TZ:]", "") }

source "amazon-ebs" "hashistack-primary" {
  region                = var.region-primary
  ami_name              = "hashistack-${local.timestamp}"
  source_ami            = "${data.amazon-ami.ubuntu-primary.id}"
  instance_type         = "t2.medium"
  ssh_username          = "ubuntu"
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name          = var.name
    source        = "hashicorp/learn"
    purpose       = "demo"
    OS_Version    = "Ubuntu"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

  snapshot_tags = {
    Name    = var.name
    source  = "hashicorp/learn"
    purpose = "demo"
  }
}

source "amazon-ebs" "hashistack-secondary" {
  region                = var.region-secondary
  ami_name              = "hashistack ${local.timestamp}"
  source_ami            = "${data.amazon-ami.ubuntu-secondary.id}"
  instance_type         = "t2.medium"
  ssh_username          = "ubuntu"
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name          = var.name
    source        = "hashicorp/learn"
    purpose       = "demo"
    OS_Version    = "Ubuntu"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
  }

  snapshot_tags = {
    Name   = var.name
    source = "hashicorp/learn"
  }
}

build {
  sources = [
    "source.amazon-ebs.hashistack-primary",
    "source.amazon-ebs.hashistack-secondary",
  ]

  provisioner "shell" {
    inline = ["sudo mkdir /ops", "sudo chmod 777 /ops"]
  }

  provisioner "file" {
    source      = "./"
    destination = "/ops"
  }

  provisioner "file" {
    source      = "../learn-nomad-edge.pub"
    destination = "/tmp/learn-nomad-edge.pub"
  }

  provisioner "shell" {
    environment_vars = ["INSTALL_NVIDIA_DOCKER=false"]
    inline           = ["/usr/bin/cloud-init status --wait && /ops/scripts/setup.sh"]
  }
}
