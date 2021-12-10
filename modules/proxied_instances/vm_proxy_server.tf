resource "aws_instance" "proxy_server" {
  count                     = var.proxy_server_count
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.proxy_server.id]

  tags = {
    Name = lower(join("-",[var.environment,element(var.proxy_server_ids, count.index)]))
  }
 
  provisioner "file" {
    source      = "${path.module}/config_files/squid.conf"
    destination = "/tmp/squid.conf"
  }

  provisioner "remote-exec" {
    inline = [
    ## Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",

    ## Apply Updates
      "sudo apt-get update",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
  
    ## Install Proxy Server
      "sudo apt-get install squid -y",
      "sudo mv /etc/squid/squid.conf /etc/squid/squid.bak",
      "sudo mv /tmp/squid.conf /etc/squid/squid.conf",
      "sudo systemctl restart squid",

    ## Install Otel Agent
      "sudo curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh",
      "sudo sh /tmp/splunk-otel-collector.sh --realm ${var.realm}  -- ${var.access_token} --mode agent",
    ]
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "proxy_server_details" {
  value =  formatlist(
    "%s, %s, %s", 
    aws_instance.proxy_server.*.tags.Name,
    aws_instance.proxy_server.*.public_ip,
    aws_instance.proxy_server.*.private_ip,
  )
}