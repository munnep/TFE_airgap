#!/bin/bash
touch /tmp/script_has_run.txt 

sudo apt-get update
sudo apt install awscli -y


aws s3 cp s3://${tag_prefix}-software/${filename_airgap} /tmp/${filename_airgap}
aws s3 cp s3://${tag_prefix}-software/${filename_license} /tmp/${filename_license}
aws s3 cp s3://${tag_prefix}-software/${filename_bootstrap} /tmp/${filename_bootstrap}
aws s3 cp s3://${tag_prefix}-software/${filename_certificate_private_key} /tmp/${filename_certificate_private_key}
aws s3 cp s3://${tag_prefix}-software/${filename_certificate_fullchain} /tmp/${filename_certificate_fullchain}
