#!/usr/bin/env bash

# exit if any failure occurred
set -o errexit
set -o nounset
set -o pipefail

UBUNTU_CODE_NAME="$(awk -F'=' '/UBUNTU_CODENAME/{print$2}' /etc/os-release)"

# basic requirements
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-transport-https ca-certificates curl gnupg

# setup docker repository
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | sudo apt-key add -qq -
echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu ${UBUNTU_CODE_NAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list

# setup docker daemon
# HINT: pinned docker-ce version to avoid breaking changes
PKG_VERSION_DOCKER="5:19.03.15~3-0~ubuntu"
PKG_VERSION_CONTAINERD="1.4.6-1"

sudo apt-get update -qq >/dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    docker-ce="${PKG_VERSION_DOCKER}-${UBUNTU_CODE_NAME}" \
    docker-ce-cli="${PKG_VERSION_DOCKER}-${UBUNTU_CODE_NAME}" \
    containerd.io="${PKG_VERSION_CONTAINERD}"

sudo apt-mark hold docker-ce
sudo apt-mark hold docker-ce-cli
sudo apt-mark hold containerd.io

# allow user "ubuntu" to execute "docker" without "sudo"
sudo usermod -aG docker ubuntu

# ensure docker will start on boot
sudo systemctl enable docker.service

# set docker bridge ip and restart service
echo '{"bip": "172.29.0.1/16"}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker.service

# setup docker-compose
DOCKER_COMPOSE_VERSION="$(curl -sLI https://github.com/docker/compose/releases/latest -o /dev/null -w '%{url_effective}' | cut -d '/' -f 8)"
sudo curl -o /usr/local/bin/docker-compose \
          -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# ensure system packages are up to date
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -y

# common packages
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    fail2ban \
    git \
    iftop \
    jq \
    openssh-client \
    openssh-server \
    tcpdump \
    tree \
    vim \
    wget

# setup awscli via snap
sudo snap install aws-cli --classic --stable # HINT: to prevent too many dependencies being installed
