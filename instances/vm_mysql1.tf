# data "template_cloudinit_config" "user_data_mysql1" {
#   gzip          = true
#   base64_encode = true
# }

resource "aws_instance" "mysql1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.mysql1_ip
  # user_data     = data.template_cloudinit_config.user_data_mysql1.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_mysql_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "MySQL1"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_mysql.sh"
    destination = "/tmp/install_mysql.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/agent_mysql.yaml"
    destination = "/tmp/agent.yaml"
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
      "AGENTVERSION=${var.smart_agent_version}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
      "sudo apt-mark hold signalfx-agent",

      "sudo chmod +x /tmp/install_mysql.sh",
      "sudo /tmp/install_mysql.sh",
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