data "template_cloudinit_config" "user_data_smart_gateway1" {
  gzip          = true
  base64_encode = true

  # get install_smart-gateway.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_smart-gateway.sh")}"
  }

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }

}

resource "aws_instance" "smart-gateway1" {
  ami           = var.ami
  instance_type = var.smart_gateway_instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.smart_gateway1_ip
  user_data     = data.template_cloudinit_config.user_data_smart_gateway1.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    "${var.allow_all_id}",
    ]

  tags = {
    Name = "Smart-Gateway1"
  }
 
  provisioner "file" {
    source      = "${path.module}/config_files/gateway1.conf"
    destination = "/tmp/gateway.conf"
  }

  provisioner "file" {
    source      = "${path.module}/agents/agent_smart-gateway.yaml"
    destination = "/tmp/agent.yaml"
  }
  
  provisioner "file" {
    source      = "${path.module}/config_files/smart-gateway1.service"
    destination = "/tmp/smart-gateway.service"
  }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/lib/gateway/smart-gateway ]; do sleep 2; done",
      "while [ ! -f /etc/signalfx/agent.yaml ]; do sleep 2; done",
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/gateway.conf /var/lib/gateway/etc/gateway.conf",
      "sudo chown root:root /var/lib/gateway/etc/gateway.conf",
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
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