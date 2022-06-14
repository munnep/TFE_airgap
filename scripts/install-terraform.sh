#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive


# install terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

apt-get update -y
apt-get install -y terraform