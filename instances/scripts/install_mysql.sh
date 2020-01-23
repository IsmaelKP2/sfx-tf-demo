#! /bin/bash

# Download and Install the Latest Updates for the OS
apt-get update
apt-get upgrade -y

# Enable Ubuntu Firewall and allow SSH & MySQL Ports
# ufw enable
# ufw allow 22
# ufw allow 3306

# Install essential packages
apt-get -y install zsh htop

# Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
echo "mysql-server mysql-server/root_password password root" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password root" | sudo debconf-set-selections
apt-get -y install mysql-server
service mysql restart