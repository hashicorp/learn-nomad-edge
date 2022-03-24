provider "aws" {
  region = var.region
}

data "template_file" "user_data_server" {
  template = file("${path.module}/data-scripts/user-data-server.sh")

  vars = {
    server_count = var.server_count
    region       = var.region
    retry_join = chomp(
      join(
        " ",
        formatlist("%s=%s", keys(var.retry_join), values(var.retry_join)),
      ),
    )
    nomad_binary = var.nomad_binary
  }
}

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  vpc_security_group_ids = [var.primary_security_group_id]
  count                  = var.server_count
  subnet_id              = var.public_subnets[0]

  # instance tags
  tags = merge(
    {
      "Name" = "${var.name}-server-${count.index}"
    },
    {
      "${var.retry_join.tag_key}" = "${var.retry_join.tag_value}"
    },
    {
      "NomadType" = "server"
    }
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_server.rendered
  iam_instance_profile = var.iam_instance_profile_name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}

resource "aws_elb" "server_lb" {
  name      = "${var.name}-server-lb"
  internal  = false
  instances = aws_instance.server.*.id
  listener {
    instance_port     = 4646
    instance_protocol = "http"
    lb_port           = 4646
    lb_protocol       = "http"
  }
  security_groups = [var.primary_security_group_id]
  subnets         = var.public_subnets
}