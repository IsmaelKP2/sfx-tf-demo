resource "aws_instance" "mysql" {
  count                     = var.mysql_count
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  tags = {
    Name = lower(join("_",[var.environment,element(var.mysql_ids, count.index)]))
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_mysql.sh"
    destination = "/tmp/install_mysql.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_splunk_otel_collector.sh"
    destination = "/tmp/update_splunk_otel_collector.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/mysql_agent_config.yaml"
    destination = "/tmp/mysql_agent_config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      #"AGENTVERSION=${var.smart_agent_version}",
      "LBURL=${aws_lb.collector-lb.dns_name}",

      # "sudo chmod +x /tmp/install_sfx_agent.sh",
      # "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      # "sudo chmod +x /tmp/update_signalfx_config.sh",
      # "sudo /tmp/update_signalfx_config.sh $LBURL",

      # "sudo mkdir /etc/signalfx/monitors",
      # "sudo mv /tmp/mysql.yaml /etc/signalfx/monitors/mysql.yaml",
      # "sudo chown root:root /etc/signalfx/monitors/mysql.yaml",
      # "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      # "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

    ## Install MySQL
      "sudo chmod +x /tmp/install_mysql.sh",
      "sudo /tmp/install_mysql.sh",
    
    ## Install Otel Agent
      "sudo curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh",
      "sudo sh /tmp/splunk-otel-collector.sh --realm ${var.realm}  -- ${var.access_token} --mode agent --without-fluentd",
      "sudo chmod +x /tmp/update_splunk_otel_collector.sh",
      "sudo /tmp/update_splunk_otel_collector.sh $LBURL",
      "sudo mv /etc/otel/collector/agent_config.yaml /etc/otel/collector/agent_config.bak",
      "sudo mv /tmp/mysql_agent_config.yaml /etc/otel/collector/agent_config.yaml",
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

output "mysql_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.mysql.*.tags.Name,
    aws_instance.mysql.*.public_ip,
  )
}