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
    source      = "${path.module}/scripts/update_sfx_environment.sh"
    destination = "/tmp/update_sfx_environment.sh"
  }

  provisioner "file" {
    source      = "${path.module}/agents/free_disk.yaml"
    destination = "/tmp/free_disk.yaml"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/java_app.sh"
    destination = "/tmp/java_app.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/run_splunk_lambda_apm.sh"
    destination = "/tmp/run_splunk_lambda_apm.sh"
  }

#### TESTING ####
  provisioner "file" {
    source      = "${path.module}/scripts/generate_load_vars.sh"
    destination = "/tmp/generate_load_vars.sh"
  }
  #### TESTING ####

# remote-exec
  provisioner "remote-exec" {
    inline = [
    # Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      
    # Update
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

    # Add Data partition
      "sudo mkdir /media/data",
      "sudo echo 'type=83' | sudo sfdisk /dev/xvdg",
      "sudo mkfs.ext4 /dev/xvdg1",
      "sudo mount /dev/xvdg1 /media/data",

    # Install SignalFx
      "TOKEN=${var.auth_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "CLUSTERNAME=${var.cluster_name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "LBURL=${aws_lb.collector-lb.dns_name}",
      "ENVIRONMENT=${var.environment}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $CLUSTERNAME $AGENTVERSION",
      
      "sudo chmod +x /tmp/update_signalfx_config.sh",
      "sudo /tmp/update_signalfx_config.sh $LBURL",

      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT",

    # Add free disk monitor
      "sudo mkdir /etc/signalfx/monitors",
      "sudo mv /tmp/free_disk.yaml /etc/signalfx/monitors/free_disk.yaml",
      "sudo chown root:root /etc/signalfx/monitors/free_disk.yaml",

    ## Install Maven
      "JAVA_APP_URL=${var.java_app_url}",
      "INVOKE_URL=${var.aws_api_gateway_deployment_retailorder_invoke_url}",
      "sudo chmod +x /tmp/java_app.sh",
      "ENV_PREFIX=${var.environment}",
      "sudo /tmp/java_app.sh $JAVA_APP_URL $INVOKE_URL $ENV_PREFIX",

    ## Install seige pre-reqs
      "sudo apt-get update",
      "sudo apt install looptools -y",
      "sudo apt install siege -y",

    ## Java App Helper Script
      "sudo chmod +x /tmp/run_splunk_lambda_apm.sh",
      "sudo mv /tmp/run_splunk_lambda_apm.sh /home/ubuntu/run_splunk_lambda_apm.sh",

      ## Set correct permissions on SplunkLambdaAPM directory
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/SplunkLambdaAPM",

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

output "app_server_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.app_server.*.tags.Name,
    aws_instance.app_server.*.public_ip,
  )
}