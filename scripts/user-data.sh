#!/bin/bash

# Download all the software and files needed
aws s3 cp s3://${tag_prefix}-software/${filename_airgap} /tmp/${filename_airgap}
aws s3 cp s3://${tag_prefix}-software/${filename_license} /tmp/${filename_license}
aws s3 cp s3://${tag_prefix}-software/${filename_bootstrap} /tmp/${filename_bootstrap}
aws s3 cp s3://${tag_prefix}-software/certificate_pem /tmp/certificate_pem
aws s3 cp s3://${tag_prefix}-software/issuer_pem /tmp/issuer_pem
aws s3 cp s3://${tag_prefix}-software/private_key_pem /tmp/private_key_pem

cat /tmp/certificate_pem >> /tmp/fullchain_pem
cat /tmp/issuer_pem >> /tmp/fullchain_pem

# set the hostname
sudo hostnamectl set-hostname ${dns_hostname}

# directory for unzipping the file
sudo mkdir /opt/tfe
sudo mv /tmp/replicated.tar.gz /opt/tfe
pushd /opt/tfe
sudo tar xzf replicated.tar.gz


cat > /tmp/tfe_settings.json <<EOF
{
   "aws_instance_profile": {
        "value": "1"
    },
    "enc_password": {
        "value": "${tfe_password}"
    },
    "hostname": {
        "value": "${dns_hostname}.${dns_zonename}"
    },
    "pg_dbname": {
        "value": "${pg_dbname}"
    },
    "pg_netloc": {
        "value": "${pg_address}"
    },
    "pg_password": {
        "value": "${rds_password}"
    },
    "pg_user": {
        "value": "postgres"
    },
    "placement": {
        "value": "placement_s3"
    },
    "production_type": {
        "value": "external"
    },
    "s3_bucket": {
        "value": "${tfe_bucket}"
    },
    "s3_endpoint": {},
    "s3_region": {
        "value": "${region}"
    }
}
EOF


# replicated.conf file
cat > /etc/replicated.conf <<EOF
{
    "DaemonAuthenticationType":          "password",
    "DaemonAuthenticationPassword":      "${tfe_password}",
    "TlsBootstrapType":                  "server-path",
    "TlsBootstrapHostname":              "${dns_hostname}.${dns_zonename}",
    "TlsBootstrapCert":                  "/tmp/fullchain_pem",
    "TlsBootstrapKey":                   "/tmp/private_key_pem",
    "BypassPreflightChecks":             true,
    "ImportSettingsFrom":                "/tmp/tfe_settings.json",
    "LicenseFileLocation":               "/tmp/${filename_license}",
    "LicenseBootstrapAirgapPackagePath": "/tmp/${filename_airgap}"
}
EOF

sudo ./install.sh airgap private-address=${tfe-private-ip}
