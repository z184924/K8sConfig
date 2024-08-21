#!/bin/bash
apt update
apt-get update
apt install -y sudo
apt install -y openssh-server
mkdir /run/sshd
/usr/sbin/sshd &
useradd admin
usermod -d /data/home/admin admin
chown -R admin:admin /data/home/admin
echo 'admin   ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers
echo 'new user admin password'
passwd admin
