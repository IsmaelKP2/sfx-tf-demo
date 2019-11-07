data "template_cloudinit_config" "user_data_smart_gateway" {
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

resource "aws_instance" "smart-gateway" {
  count         = "${var.smart_gateway_server_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name      = "geoffh"
  user_data     = "${data.template_cloudinit_config.user_data_smart_gateway.rendered}"
  vpc_security_group_ids  = [
    "${data.terraform_remote_state.security_groups.outputs.allow_egress_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_tls_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_http_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_ssh_id}",
    ]

  tags = {
    Name = "Smart-Gateway${count.index + 1}"
  }
 
  # provisioner "local-exec" {
  #   command = "echo ${self.private_ip} > Smart-Gateway-Private-IP.txt"
  # }

  # provisioner "local-exec" {
  #   command = "echo ${self.public_ip} > Smart-Gateway-Public-IP.txt"
  # }

  provisioner "file" {
    source      = "gateway.conf"
    destination = "/tmp/gateway.conf"
  }

  provisioner "file" {
    source      = "agents/agent_smart-gateway.yaml"
    destination = "/tmp/agent.yaml"
  }
  
  provisioner "file" {
    source      = "smart-gateway.service"
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
    host = "${self.public_ip}"
    type = "ssh"
    user = "ubuntu"
    private_key = "${file("~/.ssh/id_rsa")}"
    agent = "true"
  }
}