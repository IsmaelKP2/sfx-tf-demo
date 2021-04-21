resource "aws_instance" "phone_shop_server" {
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, 0)
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.phone_shop.id]
 
  tags = {
    # Name = "pss1"
    Name = "${var.environment}_pss"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/update_sfx_environment.sh"
    destination = "/tmp/update_sfx_environment.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/java_app.sh"
    destination = "/tmp/java_app.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/run_splunk_lambda_apm.sh"
    destination = "/tmp/run_splunk_lambda_apm.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/phoneshop_service.sh"
    destination = "/tmp/phoneshop_service.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/phoneshop.service"
    destination = "/tmp/phoneshop.service"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/locustfile.py"
    destination = "/tmp/locustfile.py"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/locust.service"
    destination = "/tmp/locust.service"
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
      "ENVIRONMENT=${var.environment}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      
      "sudo chmod +x /tmp/update_sfx_environment.sh",
      "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT",

    ## Phone Shop App
      ## Install Maven and update cofiguration
      "JAVA_APP_URL=${var.java_app_url}",
      "INVOKE_URL=${aws_api_gateway_deployment.retailorder.invoke_url}",
      "sudo chmod +x /tmp/java_app.sh",
      "ENV_PREFIX=${var.environment}",
      "sudo /tmp/java_app.sh $JAVA_APP_URL $INVOKE_URL $ENV_PREFIX",
      
      ## create clean version so we can run as a service
      "cd /home/ubuntu/SplunkLambdaAPM/MobileShop/APM/ && sudo mvn clean package",

      ## Java App Helper Script
      ## Scrip to assist in manually running app if required
      ## Note: it should be running as a service
      "sudo chmod +x /tmp/run_splunk_lambda_apm.sh",
      "sudo mv /tmp/run_splunk_lambda_apm.sh /home/ubuntu/run_splunk_lambda_apm.sh",

      ## Set correct permissions on SplunkLambdaAPM directory
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/SplunkLambdaAPM",

      ## Run phoneshop as a service
      ## The APM Version of the APM Workshop Phone Shop app will be
      ## installed and auto started to enable auto generation
      ## of data by the Locust load generation sofware
      "sudo chmod +x /tmp/phoneshop_service.sh",
      "sudo chown root:root /tmp/phoneshop_service.sh",
      "sudo chmod +x /tmp/phoneshop.service",
      "sudo chown root:root /tmp/phoneshop.service",
      "sudo mv /tmp/phoneshop_service.sh /usr/local/bin/phoneshop_service.sh",
      "sudo mv /tmp/phoneshop.service /etc/systemd/system/phoneshop.service",
      "sudo systemctl daemon-reload",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/SplunkLambdaAPM/MobileShop/APM/target",
      "sudo service phoneshop restart",

      ## Install Locust.io for load generation
      ## Locust will generate a random load against the phone shop app
      ## ensuring traces are generated on a regular basis to keep APM
      ## dashboards alive - Phone Shop UI can be used to inject bad data
      ## http://<public-ip-address>:8080/order
      "sudo apt-get install python3 -y",
      "sudo apt-get install python3-pip -y",
      "sudo -H pip3 install locust",
      "sudo chmod +x locustfile.py",
      "sudo chmod +x locustfile.service",
      "sudo mv /tmp/locustfile.py /home/ubuntu/locustfile.py",
      "sudo mv /tmp/locust.service /etc/systemd/system/locust.service",
      "sudo systemctl daemon-reload",
      "sudo service locust restart",

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

output "phone_shop_server_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.phone_shop_server.*.tags.Name,
    aws_instance.phone_shop_server.*.public_ip,
  )
}