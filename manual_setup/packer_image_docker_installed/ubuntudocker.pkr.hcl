variable "region" {
  type    = string
  default = "us-west-2"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntudocker" {
  ami_name      = "ubuntudocker"
  instance_type = "t2.micro"
  region        = "${var.region}"
  source_ami_filter {
    filters = {
      name = "ubuntu/images/*ubuntu-focal-*-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  name    = "ubuntudocker"
  sources = [
    "source.amazon-ebs.ubuntudocker",
  ]

  provisioner "shell" {
     script = "scripts/install_docker.sh"
  }
}