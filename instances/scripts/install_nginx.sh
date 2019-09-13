#! /bin/bash

# Download and Install the Latest Updates for the OS
apt-get update
apt-get upgrade -y

# Prepare for Nginx install
# wget http://nginx.org/keys/nginx_signing.key
# apt-key add nginx_signing.key
# echo 'deb http://nginx.org/packages/ubuntu xenial nginx' | sudo tee -a /etc/apt/sources.list
# echo 'deb-src http://nginx.org/packages/ubuntu xenial nginx' | sudo tee -a /etc/apt/sources.list

# Install Nginx
apt-get install nginx -y

# Create basic home page
# echo "<h1>NginX Deployed via Terraform</h1>" | sudo tee -a /usr/share/nginx/html/index.html

# Start Nginx Service
service nginx start