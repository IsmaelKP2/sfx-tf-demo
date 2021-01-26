resource "aws_instance" "app_server" {
  count         = var.app_server_count
  ami           = data.aws_ami.latest-ubuntu.id
  instance_type = var.instance_type
  subnet_id     = element(var.subnet_ids, count.index)

  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }
  ebs_block_device {
    device_name = "/dev/xvdg"
    volume_size = 8
    volume_type = "gp2"
  }
  key_name      = var.key_name
  vpc_security_group_ids  = [
    var.sg_allow_egress_id,
    var.sg_allow_ssh_id,
    var.sg_web_id,
    ]

  tags = {
    Name  = lower(element(var.app_server_ids, count.index))
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_signalfx_config.sh"
    destination = "/tmp/update_signalfx_config.sh"
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

  provisioner "file" {
    source      = "${path.module}/agents/free_disk.yaml"
    destination = "/tmp/free_disk.yaml"
  }

  #### TESTING ####
  # provisioner "file" {
  #   source      = "${path.module}/scripts/generate_load_vars.sh"
  #   destination = "/tmp/generate_load_vars.sh"
  # }
  #### TESTING ####

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "sudo mkdir /media/data",
      "sudo echo 'type=83' | sudo sfdisk /dev/xvdg",
      "sudo mkfs.ext4 /dev/xvdg1",
      "sudo mount /dev/xvdg1 /media/data",

      "TOKEN=${var.auth_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "CLUSTERNAME=${var.cluster_name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "LBURL=${aws_lb.collector-lb.dns_name}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",
      "sudo chmod +x /tmp/update_signalfx_config.sh",
      "sudo /tmp/update_signalfx_config.sh $LBURL",

      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

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

      "sudo mv /tmp/test-python-app.service /etc/systemd/system/test-python-app.service",
      "sudo chown root:root /etc/systemd/system/test-python-app.service",
      "sudo systemctl enable test-python-app.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart test-python-app"
    ]
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "app_server_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.app_server.*.tags.Name,
    aws_instance.app_server.*.public_ip,
  )
}