data "template_cloudinit_config" "user_data_haproxy2" {
  gzip          = true
  base64_encode = true

  # get install_haproxy.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_haproxy.sh")}"
  }

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }

}

resource "aws_instance" "haproxy2" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  private_ip    = var.haproxy2_ip
  key_name      = var.key_name
  user_data     = data.template_cloudinit_config.user_data_haproxy2.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "HAProxy2"
  }
 
  provisioner "file" {
    source      = "${path.module}/agents/agent_haproxy.yaml"
    destination = "/tmp/agent.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/haproxy/haproxy.cfg ]; do sleep 2; done",
      "while [ ! -f /etc/signalfx/agent.yaml ]; do sleep 2; done",
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
      "sudo usermod -a -G haproxy signalfx-agent",
      "sudo service signalfx-agent restart",
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