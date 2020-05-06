# data "template_cloudinit_config" "user_data_app_server2" {
#   gzip          = true
#   base64_encode = true
# }

resource "aws_instance" "app-server2" {
  ami           = var.ami
  instance_type = var.instance_type
  root_block_device {
    volume_size           = 16
    volume_type           = "gp2"
  }
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  private_ip    = var.app-server2_ip
  # user_data     = data.template_cloudinit_config.user_data_app_server2.rendered
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "App-Server2"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_app-server_agent-yaml.sh"
    destination = "/tmp/generate_app-server_agent-yaml.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/post_data.json"
    destination = "/tmp/post_data.json"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/demo.py"
    destination = "/tmp/demo.py"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/test-python-app.service"
    destination = "/tmp/test-python-app.service"
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
      "ENDPOINT=${var.traceEndpointUrl}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",
      "sudo chmod +x /tmp/generate_app-server_agent-yaml.sh",
      "sudo /tmp/generate_app-server_agent-yaml.sh $ENDPOINT $HOSTNAME",
      "sudo apt-mark hold signalfx-agent",

      "sudo apt-get install default-jre -y",
      "sudo apt-get install openjdk-11-jre-headless -y",
      "sudo apt-get install openjdk-8-jre-headless -y",
      "sudo apt-get install maven -y",
      "sudo apt-get install python3-distutils -y",
      "sudo apt-get install apache2-utils -y",

      "mkdir /home/ubuntu/mypythonapp",
      "mv /tmp/post_data.json /home/ubuntu/mypythonapp/post_data.json",
      "sudo chown 0644 /home/ubuntu/mypythonapp/post_data.json",
      "mv /tmp/demo.py /home/ubuntu/mypythonapp/demo.py",
      "sudo chown 0755 /home/ubuntu/mypythonapp/demo.py",
      "sudo chmod +x /home/ubuntu/mypythonapp/demo.py",

      "sudo curl -L https://github.com/signalfx/streaming-analytics-workshop/raw/master/apm/java-app.tar.gz -o /run/java-app.tar.gz",
      "sudo tar xvfz /run/java-app.tar.gz -C /home/ubuntu/",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu",
      "sudo curl https://bootstrap.pypa.io/get-pip.py -o /run/get-pip.py",
      "sudo -H python3 /run/get-pip.py",
      "sudo -H pip install flask requests signalfx-tracing",
      "sudo -H sfx-py-trace-bootstrap",

      # "sudo mv /tmp/test-python-app.service /lib/systemd/system/test-python-app.service",
      # "sudo chown root:root /lib/systemd/system/test-python-app.service",
      # "sudo systemctl enable test-python-app.service",
      # "sudo systemctl daemon-reload",
      # "sudo systemctl restart test-python-app"
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
