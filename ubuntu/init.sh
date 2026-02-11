#!/bin/bash

# 备份原有的 sources.list
cp /etc/apt/sources.list /etc/apt/sources.list.backup

# 替换为阿里云镜像源 (Ubuntu 20.04 focal)
cat > /etc/apt/sources.list << EOF
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF
  
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
