resource "aws_instance" "collector" {
  count                     = var.collector_count
  ami                       = var.ami
  instance_type             = var.collector_instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
  key_name                  = var.key_name
  vpc_security_group_ids    = [
    var.sg_allow_egress_id,
    var.sg_allow_ssh_id,
    var.sg_collectors_id,
    ]

  tags = {
    Name  = lower(element(var.collector_ids, count.index))
    role = "collector"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/collector.yaml"
    destination = "/tmp/collector.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_otc_startup.sh"
    destination = "/tmp/generate_otc_startup.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_sfx_environment.sh"
    destination = "/tmp/update_sfx_environment.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/docker.yaml"
    destination = "/tmp/docker.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/agents/free_disk.yaml"
    destination = "/tmp/free_disk.yaml"
  }

  provisioner "remote-exec" {
    inline = [
    # Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

    # Install SignalFx
      "TOKEN=${var.auth_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "ENVIRONMENT=${var.environment}",
      
      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",

      "sudo sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml",
      
      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT",

      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/docker.yaml /etc/signalfx/monitors/docker.yaml",
      "sudo chown root:root /etc/signalfx/monitors/docker.yaml",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

    ## Install Docker
      "sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y",
      "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
      "sudo apt-get update",
      "sudo apt-get install docker-ce docker-ce-cli containerd.io -y",
      "sudo systemctl enable docker",

    ## Add signfx-agent to Docker Group
      "sudo usermod -a -G docker signalfx-agent",
      "sudo service signalfx-agent restart",

    ## Set Vars for Collector
      "BALLAST=${var.ballast}",
      "OTELCOL_VERSION=${var.otelcol_version}",

    ## Move collector.yaml to /home/ubuntu and update permissions
      "sudo cp /tmp/collector.yaml /home/ubuntu/collector.yaml",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/collector.yaml",

    ## Generate collector startup script so users can easily restart it (it gets created in /home/ubuntu)
      "sudo chmod +x /tmp/generate_otc_startup.sh",
      "sudo /tmp/generate_otc_startup.sh $TOKEN $BALLAST $REALM $OTELCOL_VERSION $ENVIRONMENT",

    ## Run collector
      "sudo chmod +x /home/ubuntu/otc_startup.sh",
      "sudo chown ubuntu:ubuntu /home/ubuntu/otc_startup.sh",
      "/home/ubuntu/otc_startup.sh",

    ## Configure motd
      # "sudo apt install curl -y",
      "sudo curl -s https://raw.githubusercontent.com/signalfx/observability-workshop/master/cloud-init/motd -o /etc/motd",
      "sudo chmod -x /etc/update-motd.d/*",

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

output "collector_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.collector.*.tags.Name,
    aws_instance.collector.*.public_ip,
  )
}