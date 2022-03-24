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

// data "template_file" "user_data_client" {
//   template = file("${path.root}/data-scripts/user-data-client.sh")

//   vars = {
//     region = var.region
//     servers = chomp(
//       join(
//         ", ",
//         formatlist("\"%s:4647\"", aws_instance.server.*.public_ip)
//       ),
//     )
//     nomad_binary              = var.nomad_binary
//     nomad_consul_token_secret = var.nomad_consul_token_secret
//   }
// }

resource "aws_instance" "server" {
  ami                    = var.ami
  instance_type          = var.server_instance_type
  key_name               = var.key_name
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

// resource "aws_instance" "client" {
//   ami           = var.ami
//   instance_type = var.client_instance_type
//   key_name      = var.key_name
//   vpc_security_group_ids = [
//     var.primary_security_group_id,
//     var.client_security_group_id,
//   ]
//   count      = var.client_count
//   depends_on = [aws_instance.server]
//   subnet_id  = var.public_subnets[0]

//   # instance tags
//   tags = merge(
//     {
//       "Name" = "${var.name}-client-${count.index}"
//     },
//     {
//       "${var.retry_join.tag_key}" = "${var.retry_join.tag_value}"
//     },
//   )

//   root_block_device {
//     volume_type           = "gp2"
//     volume_size           = var.root_block_device_size
//     delete_on_termination = "true"
//   }

//   ebs_block_device {
//     device_name           = "/dev/xvdd"
//     volume_type           = "gp2"
//     volume_size           = "50"
//     delete_on_termination = "true"
//   }

//   user_data            = data.template_file.user_data_client.rendered
//   iam_instance_profile = var.iam_instance_profile_name

//   metadata_options {
//     http_endpoint          = "enabled"
//     instance_metadata_tags = "enabled"
//   }
// }

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