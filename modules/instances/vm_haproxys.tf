resource "aws_instance" "haproxy" {
  count                     = var.haproxy_count
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }
  ebs_block_device {
    device_name = "/dev/xvdg"
    volume_size = 10
    volume_type = "gp2"
  }
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  tags = {
    Name = lower(join("_",[var.environment,element(var.haproxy_ids, count.index)]))
    Environment = lower(var.environment)
  }
 
  provisioner "file" {
    source      = "${path.module}/scripts/install_haproxy.sh"
    destination = "/tmp/install_haproxy.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_splunk_otel_collector.sh"
    destination = "/tmp/update_splunk_otel_collector.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/haproxy_agent_config.yaml"
    destination = "/tmp/haproxy_agent_config.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "sudo mkdir /media/data",
      "sudo echo 'type=83' | sudo sfdisk /dev/xvdg",
      "sudo mkfs.ext4 /dev/xvdg1",
      "sudo mount /dev/xvdg1 /media/data",

      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      #"AGENTVERSION=${var.smart_agent_version}",
      "LBURL=${aws_lb.collector-lb.dns_name}",
      
    ## Install HA Proxy
      "sudo chmod +x /tmp/install_haproxy.sh",
      "sudo /tmp/install_haproxy.sh",
    
    ## Install Otel Agent
      "sudo curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh",
      "sudo sh /tmp/splunk-otel-collector.sh --realm ${var.realm}  -- ${var.access_token} --mode agent --without-fluentd",
      "sudo chmod +x /tmp/update_splunk_otel_collector.sh",
      "sudo /tmp/update_splunk_otel_collector.sh $LBURL",
      "sudo mv /etc/otel/collector/agent_config.yaml /etc/otel/collector/agent_config.bak",
      "sudo mv /tmp/haproxy_agent_config.yaml /etc/otel/collector/agent_config.yaml",
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

output "haproxy_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.haproxy.*.tags.Name,
    aws_instance.haproxy.*.public_ip,
  )
}