resource "aws_instance" "nginx1" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.nginx1_ip
  # user_data     = data.template_cloudinit_config.user_data_nginx1.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "NginX1"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_nginx.sh"
    destination = "/tmp/install_nginx.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/nginx1.conf"
    destination = "/tmp/nginx.conf"
  }
  
  provisioner "file" {
    source      = "${path.module}/agents/nginx.yaml"
    destination = "/tmp/nginx.yaml"
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
      "CLUSTERNAME=${var.smart_gateway_cluster_name}",
      "AGENTVERSION=${var.smart_agent_version}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",

      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/nginx.yaml /etc/signalfx/monitors/nginx.yaml",
      "sudo chown root:root /etc/signalfx/monitors/nginx.yaml",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

      "sudo sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml",

      "sudo chmod +x /tmp/install_nginx.sh",
      "sudo /tmp/install_nginx.sh",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo chown root:root /etc/nginx/nginx.conf",
      "sudo service nginx restart",
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