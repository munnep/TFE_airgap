
resource "aws_network_interface" "terraform_client-priv" {
  subnet_id   = aws_subnet.public1.id
  private_ips = [cidrhost(cidrsubnet(var.vpc_cidr, 8, 1), 23)]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_network_interface_sg_attachment" "sg2_attachment" {
  security_group_id    = aws_security_group.default-sg.id
  network_interface_id = aws_network_interface.terraform_client-priv.id
}


resource "aws_eip" "terraform_client-eip" {
  vpc = true

  instance                  = aws_instance.terraform_client.id
  associate_with_private_ip = aws_network_interface.terraform_client-priv.private_ip
  depends_on                = [aws_internet_gateway.gw]

  tags = {
    Name = "${var.tag_prefix}-client-eip"
  }
}

resource "aws_instance" "terraform_client" {
  ami           = var.ami
  instance_type = "t3.large"
  key_name      = "patrick"

  network_interface {
    network_interface_id = aws_network_interface.terraform_client-priv.id
    device_index         = 0
  }

  iam_instance_profile = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/install-terraform.sh", {})

  tags = {
    Name = "${var.tag_prefix}-client"
  }

  depends_on = [
    aws_network_interface_sg_attachment.sg2_attachment
  ]
}