# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_security_group" "elk" {
  name   = format("%s-elk-allow", var.namespace)
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "elk_ingress" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = var.external_cidrs
  description = "Allow SSH to elk instance."

  security_group_id = aws_security_group.elk.id
}

resource "aws_security_group_rule" "elk_ingress_ui" {
  type        = "ingress"
  from_port   = 5601
  to_port     = 5601
  protocol    = "tcp"
  cidr_blocks = concat(var.external_cidrs, [var.vpc_cidr])
  description = "Allow web traffic to elk instance."

  security_group_id = aws_security_group.elk.id
}

resource "aws_security_group_rule" "elk_ingress_api_24224" {
  type        = "ingress"
  from_port   = 24224
  to_port     = 24224
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr]
  description = "Allow fluentd endpoint to be accessed from TFE."

  security_group_id = aws_security_group.elk.id
}

resource "aws_security_group_rule" "elk_ingress_api_5140" {
  type        = "ingress"
  from_port   = 5140
  to_port     = 5140
  protocol    = "tcp"
  cidr_blocks = [var.vpc_cidr]
  description = "Allow syslog endpoint to be accessed from TFE."

  security_group_id = aws_security_group.elk.id
}

resource "aws_security_group_rule" "elk_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  description = "Allow full egress from elk instance."

  security_group_id = aws_security_group.elk.id
}
