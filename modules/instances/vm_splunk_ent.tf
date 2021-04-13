resource "random_password" "splunk_password" {
  length           = 12
  special          = true
  override_special = "@£$"
}

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
    source      = "${path.module}/scripts/install_splunk.sh"
    destination = "/tmp/install_splunk.sh"
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
      
    ## Create Splunk Ent Vars
      "SPLUNK_PASSWORD=${random_password.splunk_password.result}",
      "SPLUNK_ENT_VERSION=${var.splunk_ent_version}",
      "SPLUNK_FILENAME=${var.splunk_ent_filename}",

    ## Write env vars to file (used for debugging)
      "echo $SPLUNK_PASSWORD > /tmp/splunk_password",
      "echo $SPLUNK_ENT_VERSION > /tmp/splunk_ent_version",
      "echo $SPLUNK_FILENAME > /tmp/splunk_filename",

    ## Install Splunk
      "sudo chmod +x /tmp/install_splunk.sh",
      "sudo /tmp/install_splunk.sh $SPLUNK_PASSWORD $SPLUNK_ENT_VERSION $SPLUNK_FILENAME",
    
    ## Install SignalFX Agent
      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      "sudo chmod +x /tmp/update_signalfx_config.sh",
      "sudo /tmp/update_signalfx_config.sh $LBURL",

    ## Add Monitors
      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/splunk.yaml /etc/signalfx/monitors/splunk.yaml",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/*.*",
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

output "splunk_ent_urls" {
  value =  formatlist(
    "%s%s:%s", 
    "http://",
    aws_instance.splunk_ent.*.public_ip,
    "8000",
  )
}

output "splunk_password" {
  value = random_password.splunk_password.result
}
