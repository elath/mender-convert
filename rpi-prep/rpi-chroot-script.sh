#!/bin/bash

# This script has been moved out of the main rpi-prep.sh script as it needs to be executed from within the chroot.

echo "Update apt packages."
apt update
apt -y dist-upgrade

# Add Docker's official GPG key:
apt update
apt install \
        ca-certificates \
        curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# Install docker
apt update
apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
        
# Install Mender pre-requisites
apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

curl -fsSL https://downloads.mender.io/repos/debian/gpg | tee /etc/apt/trusted.gpg.d/mender.asc
sed -i.bak -e "\,https://downloads.mender.io/repos/debian,d" /etc/apt/sources.list

echo "deb [arch=$(dpkg --print-architecture)] https://downloads.mender.io/repos/debian debian/bookworm/stable main" \
 | tee /etc/apt/sources.list.d/mender.list > /dev/null

# Install Mender
apt update
apt install mender-client4

# Install other tools
apt install -y \
        vim-common \
        openssh-server

# Enable the SSH service
ln -s /lib/systemd/system/ssh.service /etc/systemd/system/sshd.service
ln -s /lib/systemd/system/ssh.service /etc/systemd/system/multi-user.target.wants/ssh.service

echo "end of rpi-chroot-script.sh"