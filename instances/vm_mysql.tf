data "template_cloudinit_config" "user_data_mysql" {
  gzip          = true
  base64_encode = true

  # get install_mysql.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_mysql.sh")}"
  }

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }

}

resource "aws_instance" "mysql" {
  count         = "${var.mysql_server_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name      = "geoffh"
  user_data     = "${data.template_cloudinit_config.user_data_mysql.rendered}"
  vpc_security_group_ids  = [
    "${data.terraform_remote_state.security_groups.outputs.allow_egress_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_mysql_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_ssh_id}",
    ]

  tags = {
    Name = "MySQL${count.index + 1}"
  }

  provisioner "file" {
    source      = "agents/agent_mysql.yaml"
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
    host = "${self.public_ip}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent = "true"
  }
}