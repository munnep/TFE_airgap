variable "tag_prefix" {
  description = "default prefix of names"
}

variable "region" {
  description = "region to create the environment"
}

variable "vpc_cidr" {
  description = "which private subnet do you want to use for the VPC. Subnet mask of /16"
}

variable "ami" {
  description = "Must be an Ubuntu image that is available in the region you choose"
}

variable "rds_password" {
  description = "password for the RDS postgres database user"
}

variable "tfe_password" {
  description = "password for tfe user"
}

# variable "myownpublicip" {
#   description = "your own public up to connect to the internet"
# }

variable "filename_airgap" {
  description = "filename of your airgap installation located under directory airgap"
}

variable "filename_license" {
  description = "filename of your license located under directory airgap"
}

variable "filename_bootstrap" {
  description = "filename of your bootstrap located under directory airgap"
}

# variable "filename_certificate_private_key" {
#   description = "filename of your certificate_private_key located under directory airgap"
# }

# variable "filename_certificate_fullchain" {
#   description = "filename of your certificate_fullchain located under directory airgap"
# }

variable "dns_hostname" {
  description = "DNS hostname"
}

variable "dns_zonename" {
  description = "DNS zonename"
}

variable "certificate_email" {
  description = "email address to register the certificate"
}