# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "dns" {
  description = "DNS of fluentd."
  value = {
    public  = aws_instance.elk.public_dns
    private = aws_instance.elk.private_dns
  }
}
