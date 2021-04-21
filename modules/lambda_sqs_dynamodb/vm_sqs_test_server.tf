resource "aws_instance" "sqs_test_server" {
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, 0)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.lambda_sqs_lambda_sg.id]

  tags = {
    Name  = "sqs_test"
  }

  provisioner "file" {
    source      = "${path.module}/send_message.py"
    destination = "/tmp/sendmessage.py"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_send_messages.sh"
    destination = "/tmp/generate_send_messages.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_aws_config.sh"
    destination = "/tmp/generate_aws_config.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_sfx_environment.sh"
    destination = "/tmp/update_sfx_environment.sh"
  }

# remote-exec
  provisioner "remote-exec" {
    inline = [
    # Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      
    # Update
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

    # Install SignalFx
      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT",
 
    ## Setup testing env
      "sudo apt install python3 -y",
      "sudo apt-get update",
      "sudo apt install python3-pip -y",
      "pip3 install boto3 --user",
      "pip3 install python-dateutil --user",
      "pip3 install faker --user",
      "sudo mv /tmp/sendmessage.py /home/ubuntu/send_message.py",
      "sudo chmod +x /tmp/generate_send_messages.sh",
      "QUEUE=${var.environment}-messages",
      "/tmp/generate_send_messages.sh $QUEUE",
      "sudo chmod +x /home/ubuntu/send_messages.sh",

    ## Setup AWS Cli
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip",
      "sudo apt install unzip",
      "sudo unzip /tmp/awscliv2.zip",
      "sudo /tmp/aws/install",
      "sudo chmod +x /tmp/generate_aws_config.sh",
      "AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      "REGION=${var.region}",
      "/tmp/generate_aws_config.sh $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $REGION",

    ## Write env vars to file (used for debugging)
      "echo $AWS_ACCESS_KEY_ID > /tmp/aws_access_key_id",
      "echo $AWS_SECRET_ACCESS_KEY > /tmp/aws_secret_access_key",
      "echo $REGION > /tmp/region",

    ## Set permissions on home folder
      "sudo chown -R ubuntu:ubuntu /home/ubuntu",

    ## Configure motd
      "sudo curl -s https://raw.githubusercontent.com/signalfx/observability-workshop/master/cloud-init/motd -o /etc/motd",
      "sudo chmod -x /etc/update-motd.d/*",
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

output "sqs_test_server_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.sqs_test_server.*.tags.Name,
    aws_instance.sqs_test_server.*.public_ip,
  )
}