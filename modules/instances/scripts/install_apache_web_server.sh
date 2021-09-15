#! /bin/bash

# Download and Install the Latest Updates for the OS
apt-get update
apt-get upgrade -y

# # Set the Server Timezone to CST
# echo "America/Chicago" > /etc/timezone
# dpkg-reconfigure -f noninteractive tzdata

# Enable Ubuntu Firewall and allow SSH & HTTP/S Ports
# ufw enable
# ufw allow 22
# ufw allow 80
# ufw allow 443

# Install Apache2
apt-get install -y apache2
systemctl start apache2
systemctl enable apache2

# Create basic web page
echo "<h1>Apache2 Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html