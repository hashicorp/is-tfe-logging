# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_ami" "ubuntu" {
  owners      = ["099720109477", "513442679011"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

data "template_file" "elk_config" {
  template = file("${path.module}/templates/user_data.sh.tpl")

  vars = {
    repo   = var.tfe_elk_repo
    branch = var.tfe_elk_branch
  }
}
