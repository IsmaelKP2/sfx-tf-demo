# data "template_cloudinit_config" "user_data_smart_gateway2" {
#   gzip          = true
#   base64_encode = true

#   # get install_smart-gateway.sh
#   part {
#     content_type = "text/x-shellscript"
#     content      = "${file("${path.module}/scripts/install_smart-gateway.sh")}"
#   }

#   # get install_sfx_agent.sh
#   part {
#     content_type = "text/x-shellscript"
#     content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
#   }

# }

resource "aws_instance" "smart-gateway2" {
  ami           = var.ami
  instance_type = var.smart_gateway_instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.smart_gateway2_ip
  # user_data     = data.template_cloudinit_config.user_data_smart_gateway2.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    "${var.allow_all_id}",
    ]

  tags = {
    Name = "Smart-Gateway2"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_smart-gateway.sh"
    destination = "/tmp/install_smart-gateway.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/agent_smart-gateway.yaml"
    destination = "/tmp/agent.yaml"
  }
  
  provisioner "file" {
    source      = "${path.module}/config_files/smart-gateway2.service"
    destination = "/tmp/smart-gateway.service"
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
      "CLUSTERNAME=${var.smart_gateway_cluster_name}",
      "GATEWAYVERSION=${var.smart_gateway_version}",
      "AGENTVERSION=${var.smart_agent_version}",
      
      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
      "sudo apt-mark hold signalfx-agent",
      
      "sudo chmod +x /tmp/install_smart-gateway.sh",
      "sudo /tmp/install_smart-gateway.sh $TOKEN $REALM $HOSTNAME $CLUSTERNAME $GATEWAYVERSION",
      "sudo mv /tmp/smart-gateway.service /lib/systemd/system/smart-gateway.service",
      "sudo chown root:root /lib/systemd/system/smart-gateway.service",
      "sudo systemctl enable smart-gateway.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart smart-gateway"
    ]
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    agent = "true"
  }
}