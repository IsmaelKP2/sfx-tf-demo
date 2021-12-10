resource "aws_instance" "proxied_apache_web" {
  count                     = var.proxied_apache_web_count
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.proxied_instances_sg.id]

  tags = {
    Name = lower(join("-",[var.environment,element(var.proxied_apache_web_ids, count.index)]))
  }
 
  provisioner "file" {
    source      = "${path.module}/scripts/install_apache_web_server.sh"
    destination = "/tmp/install_apache_web_server.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/apache_web_agent_config.yaml"
    destination = "/tmp/apache_web_agent_config.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/service-proxy.conf"
    destination = "/tmp/service-proxy.conf"
  }

  provisioner "remote-exec" {
    inline = [
    ## Update Env Vars - Set Proxy
      "sudo sed -i '$ a http_proxy=http://${aws_instance.proxy_server[0].private_ip}:8080/' /etc/environment",
      "sudo sed -i '$ a https_proxy=http://${aws_instance.proxy_server[0].private_ip}:8080/' /etc/environment",
      "sudo sed -i '$ a no_proxy=169.254.169.254' /etc/environment",

    ## Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",

    ## Apply Updates
      "sudo apt-get update",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
   
    ## Install Apache
      "sudo chmod +x /tmp/install_apache_web_server.sh",
      "sudo /tmp/install_apache_web_server.sh",

    ## Install Otel Agent
      "sudo curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh",
      "sudo sh /tmp/splunk-otel-collector.sh --realm ${var.realm}  -- ${var.access_token} --mode agent",
      "sudo mv /etc/otel/collector/agent_config.yaml /etc/otel/collector/agent_config.bak",
      "sudo mv /tmp/apache_web_agent_config.yaml /etc/otel/collector/agent_config.yaml",
      "sudo chown root:root /tmp/service-proxy.conf",
      "sudo mv /tmp/service-proxy.conf /etc/systemd/system/splunk-otel-collector.service.d/service-proxy.conf",
      "sudo sed -i '$ a Environment=\"HTTP_PROXY=http://${aws_instance.proxy_server[0].private_ip}:8080\"' /etc/systemd/system/splunk-otel-collector.service.d/service-proxy.conf",
      "sudo sed -i '$ a Environment=\"HTTPS_PROXY=http://${aws_instance.proxy_server[0].private_ip}:8080\"' /etc/systemd/system/splunk-otel-collector.service.d/service-proxy.conf",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart splunk-otel-collector",
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

output "proxied_apache_web_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.proxied_apache_web.*.tags.Name,
    aws_instance.proxied_apache_web.*.public_ip,
  )
}