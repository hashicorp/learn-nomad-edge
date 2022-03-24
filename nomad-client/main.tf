provider "aws" {
  region = var.region
}

data "template_file" "user_data_client" {
  template = file("${path.module}/data-scripts/user-data-client.sh")

  vars = {
    region = var.region
    servers = chomp(
      join(
        ", ",
        formatlist("\"%s:4647\"", var.nomad_server_ips)
      ),
    )
    nomad_binary = var.nomad_binary
    targeted_dc  = var.nomad_targeted_dc
    dc           = var.nomad_dc
  }
}

resource "aws_instance" "client" {
  ami           = var.ami
  instance_type = var.client_instance_type
  vpc_security_group_ids = [
    var.primary_security_group_id,
    var.client_security_group_id,
  ]
  count     = var.client_count
  subnet_id = var.public_subnets[0]

  # instance tags
  tags = merge(
    {
      "Name" = "${var.name}-client-${count.index}"
    },
    {
      "${var.retry_join.tag_key}" = "${var.retry_join.tag_value}"
    },
  )

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

  ebs_block_device {
    device_name           = "/dev/xvdd"
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = "true"
  }

  user_data            = data.template_file.user_data_client.rendered
  iam_instance_profile = var.iam_instance_profile_name

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "enabled"
  }
}

// resource "aws_instance" "targeted_client" {
//   ami                    = var.ami
//   instance_type          = var.targeted_client_instance_type
//   vpc_security_group_ids = [aws_security_group.primary.id, aws_security_group.client_sg.id]
//   count                  = var.targeted_client_count
//   depends_on             = [aws_instance.server]

//   # instance tags
//   tags = merge(
//     {
//       "Name" = "${var.name}-targeted-client-${count.index}"
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
//   iam_instance_profile = aws_iam_instance_profile.instance_profile.name

//   metadata_options {
//     http_endpoint = "enabled"
//     instance_metadata_tags = "enabled"
//   }
// }