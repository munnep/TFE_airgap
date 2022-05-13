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
  instance_type = "t3.xlarge"
  key_name      = "patrick"

  network_interface {
    network_interface_id = aws_network_interface.tfe-priv.id
    device_index         = 0
  }

  root_block_device {
    volume_size = 50

  }


  iam_instance_profile = aws_iam_instance_profile.profile.name

  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    tag_prefix                       = var.tag_prefix
    filename_airgap                  = var.filename_airgap
    filename_license                 = var.filename_license
    filename_bootstrap               = var.filename_bootstrap
    filename_certificate_private_key = var.filename_certificate_private_key
    filename_certificate_fullchain   = var.filename_certificate_fullchain
    dns_hostname                     = var.dns_hostname
    tfe-private-ip                   = cidrhost(cidrsubnet(var.vpc_cidr, 8, 1), 22)
    tfe_password                     = var.tfe_password
    dns_zonename                     = var.dns_zonename
    pg_dbname                        = aws_db_instance.default.name
    pg_address                       = aws_db_instance.default.address
    rds_password                     = var.rds_password
    tfe_bucket                       = "${var.tag_prefix}-bucket"
    region                           = var.region
  })

  tags = {
    Name = "${var.tag_prefix}-tfe"
  }
  # sometimes the webserver is running before the NAT gateway is available. The webserver is not able to download things
  depends_on = [
    aws_network_interface_sg_attachment.sg_attachment
  ]
}