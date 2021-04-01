resource "aws_instance" "splunk_ent" {
  count                     = var.splunk_ent_count
  ami                       = var.ami
  instance_type             = var.splunk_ent_inst_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
    root_block_device {
    volume_size = 32
    volume_type = "gp2"
  }
  key_name                  = var.key_name
  vpc_security_group_ids    = [
    aws_security_group.instances_sg.id,
    aws_security_group.splunk_ent_sg.id,
  ]

  tags = {
    Name  = lower(element(var.splunk_ent_ids, count.index))
  }
 
  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_signalfx_config.sh"
    destination = "/tmp/update_signalfx_config.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/splunk.yaml"
    destination = "/tmp/splunk.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/agents/free_disk.yaml"
    destination = "/tmp/free_disk.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "TOKEN=${var.auth_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "LBURL=${aws_lb.collector-lb.dns_name}",
      
      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      "sudo chmod +x /tmp/update_signalfx_config.sh",
      "sudo /tmp/update_signalfx_config.sh $LBURL",

      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/splunk.yaml /etc/signalfx/monitors/splunk.yaml",
      #"sudo chown root:root /etc/signalfx/monitors/splunk.yaml",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      #"sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/*.*",
      
      "sudo wget -O /tmp/splunk-8.1.2-545206cc9f70-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.2&product=splunk&filename=splunk-8.1.2-545206cc9f70-Linux-x86_64.tgz&wget=true'",
      "sudo tar -zxvf /tmp/splunk-8.1.2-545206cc9f70-Linux-x86_64.tgz -C /opt",
      "sudo /opt/splunk/bin/splunk cmd splunkd rest --noauth POST /services/authentication/users 'name=admin&password=password&roles=admin'",
      "sudo /opt/splunk/bin/splunk start --accept-license --answer-yes",
      "sudo /opt/splunk/bin/splunk enable boot-start",
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

output "splunk_ent_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.splunk_ent.*.tags.Name,
    aws_instance.splunk_ent.*.public_ip,
  )
}