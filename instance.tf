resource "aws_network_interface" "tfe-priv" {
  subnet_id   = aws_subnet.public1.id
  private_ips = [cidrhost(cidrsubnet(var.vpc_cidr, 8, 1), 22)]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.default-sg.id
  network_interface_id = aws_network_interface.tfe-priv.id
}

# data "cloudinit_config" "server_config" {
#   gzip          = true
#   base64_encode = true
#   part {
#     content_type = "text/cloud-config"
#     content      = file("${path.module}/scripts/webserver.yml")
#   }
# }


resource "aws_eip" "tfe-eip" {
  vpc = true

  instance                  = aws_instance.tfe_server.id
  associate_with_private_ip = aws_network_interface.tfe-priv.private_ip
  depends_on                = [aws_internet_gateway.gw]

    tags = {
    Name = "${var.tag_prefix}-eip"
  }
}

resource "aws_instance" "tfe_server" {
  ami           = var.ami
  instance_type = "t3.large"
  key_name      = "patrick"

  network_interface {
    network_interface_id = aws_network_interface.tfe-priv.id
    device_index         = 0
  }

iam_instance_profile = aws_iam_instance_profile.profile.name
#   user_data = data.cloudinit_config.server_config.rendered
  tags = {
    Name = "${var.tag_prefix}-tfe"
  }
  # sometimes the webserver is running before the NAT gateway is available. The webserver is not able to download things
  depends_on = [
    aws_network_interface_sg_attachment.sg_attachment
  ]
}