
resource "aws_instance" "wordpress1" {
  ami           = var.ami
  instance_type = var.instance_type
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
  subnet_id     = var.subnet_id
  private_ip    = var.wordpress1_ip
  vpc_security_group_ids  = [
    "${var.allow_egress_id}",
    "${var.allow_web_id}",
    "${var.allow_ssh_id}",
    ]

  tags = {
    Name = "Wordpress1"
  }
 
  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_apache.sh"
    destination = "/tmp/install_apache.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/wordpress.yaml"
    destination = "/tmp/wordpress.yaml"
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
      
      "sudo mkdir /media/data",
      "sudo echo 'type=83' | sudo sfdisk /dev/xvdg",
      "sudo mkfs.ext4 /dev/xvdg1",
      "sudo mount /dev/xvdg1 /media/data",

      "TOKEN=${var.auth_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "CLUSTERNAME=${var.smart_gateway_cluster_name}",
      "AGENTVERSION=${var.smart_agent_version}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",

      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/wordpress.yaml /etc/signalfx/monitors/wordpress.yaml",
      "sudo chown root:root /etc/signalfx/monitors/wordpress.yaml",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

      "sudo sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml",
      
      "sudo chmod +x /tmp/install_apache.sh",
      "sudo /tmp/install_apache.sh",
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