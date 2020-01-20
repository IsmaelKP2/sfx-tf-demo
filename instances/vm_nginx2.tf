data "template_cloudinit_config" "user_data_nginx2" {
  gzip          = true
  base64_encode = true

  # get install_nginx.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_nginx.sh")}"
  }

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }

}

resource "aws_instance" "nginx2" {
  # count         = var.nginx_server_count
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.nginx2_ip
  user_data     = data.template_cloudinit_config.user_data_nginx2.rendered
   vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "NginX2"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/nginx2.conf"
    destination = "/tmp/nginx.conf"
  }
  
  provisioner "file" {
    source      = "${path.module}/agents/agent_nginx.yaml"
    destination = "/tmp/agent.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/log/nginx/access.log ]; do sleep 2; done",
      "while [ ! -f /etc/signalfx/agent.yaml ]; do sleep 2; done",
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo chown root:root /etc/nginx/nginx.conf",
      "sudo service nginx restart",
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