resource "aws_instance" "elk" {
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = var.key_pair
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.elk.id]
  user_data                   = data.template_file.elk_config.rendered

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  tags = merge(var.tags,
    {
      Name = format("%s-elk", var.namespace)
  })
}
