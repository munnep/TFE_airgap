#!/bin/bash


# wait until archive is available. Wait until there is internet before continue
until ping -c1 archive.ubuntu.com &>/dev/null; do
 echo "waiting for networking to initialise"
 sleep 3 
done 

# TODO: make this in a terraform way

# add ssh key alvaro
curl -sL https://raw.githubusercontent.com/kikitux/curl-bash/master/provision/add_github_user_public_keys.sh | GITHUB_USER=kikitux bash

# add ssh key patrick
curl -sL https://raw.githubusercontent.com/kikitux/curl-bash/master/provision/add_github_user_public_keys.sh | GITHUB_USER=munnep bash


# install monitoring tools
apt-get update
apt-get install -y ctop net-tools sysstat

# Set swappiness
if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
  echo never > /sys/kernel/mm/transparent_hugepage/enabled
fi

if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
  echo never > /sys/kernel/mm/transparent_hugepage/defrag
fi

# heavy swap vm.swappiness=80
# no swap vm.swappiness=1
sysctl vm.swappiness=1
sysctl vm.min_free_kbytes=67584
sysctl vm.drop_caches=1
# make it permanent over server reboots
echo vm.swappiness=1 >> /etc/sysctl.conf
echo vm.min_free_kbytes=67584 >> /etc/sysctl.conf

SWAP=/dev/$(lsblk|grep nvme | grep -v nvme0n1 |sort -k 4 | awk '{print $1}'| awk '(NR==1)')
DOCKER=/dev/$(lsblk|grep nvme | grep -v nvme0n1 |sort -k 4 | awk '{print $1}'| awk '(NR==2)')

echo $SWAP
echo $DOCKER

# swap
# if SWAP exists
# we format if no format
if [ -b $SWAP ]; then
	blkid $SWAP
	if [ $? -ne 0 ]; then
		mkswap $SWAP
	fi
fi

# if SWAP not in fstab
# we add it
grep "swap" /etc/fstab
if [ $? -ne 0 ]; then
  SWAP_UUID=`blkid $SWAP| awk '{print $2}'`
	echo "$SWAP_UUID swap swap defaults 0 0" | tee -a /etc/fstab
	swapon -a
fi

# docker
# if DOCKER exists
# we format if no format
if [ -b $DOCKER ]; then
	blkid $DOCKER
	if [ $? -ne 0 ]; then
		mkfs.xfs $DOCKER
	fi
fi

# if DOCKER not in fstab
# we add it
grep "/var/lib/docker" /etc/fstab
if [ $? -ne 0 ]; then
  DOCKER_UUID=`blkid $DOCKER| awk '{print $2}'`
	echo "$DOCKER_UUID /var/lib/docker xfs defaults 0 0" | tee -a /etc/fstab
	mkdir -p /var/lib/docker
	mount -a
fi

# Netdata will be listening on port 19999
curl -sL https://raw.githubusercontent.com/automodule/bash/main/install_netdata.sh | bash

# install requirements for tfe
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Download all the software and files needed
apt-get -y install awscli
aws s3 cp s3://${tag_prefix}-software/${filename_airgap} /tmp/${filename_airgap}
aws s3 cp s3://${tag_prefix}-software/${filename_license} /tmp/${filename_license}
aws s3 cp s3://${tag_prefix}-software/${filename_bootstrap} /tmp/${filename_bootstrap}
aws s3 cp s3://${tag_prefix}-software/certificate_pem /tmp/certificate_pem
aws s3 cp s3://${tag_prefix}-software/issuer_pem /tmp/issuer_pem
aws s3 cp s3://${tag_prefix}-software/private_key_pem /tmp/private_key_pem

# Create a full chain from the certificates
cat /tmp/certificate_pem >> /tmp/fullchain_pem
cat /tmp/issuer_pem >> /tmp/fullchain_pem

# directory for decompress the file
sudo mkdir -p /opt/tfe
pushd /opt/tfe
sudo tar xzf /tmp/replicated.tar.gz

# create the configuration file for replicated installation
cat > /tmp/tfe_settings.json <<EOF
{
   "aws_instance_profile": {
        "value": "1"
    },
    "enc_password": {
        "value": "${tfe_password}"
    },
    "hairpin_addressing": {
        "value": "1"
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

sudo bash ./install.sh airgap private-address=${tfe-private-ip}
