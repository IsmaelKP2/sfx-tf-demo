data "template_cloudinit_config" "user_data_app_server1" {
  gzip          = true
  base64_encode = true

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }
}

resource "aws_instance" "app-server1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.app-server1_ip
  user_data     = data.template_cloudinit_config.user_data_app_server1.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "App-Server1"
  }

  provisioner "file" {
    source      = "${path.module}/agents/agent_app-server.yaml"
    destination = "/tmp/agent.yaml"
  }
  
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/signalfx/agent.yaml ]; do sleep 2; done",
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
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
