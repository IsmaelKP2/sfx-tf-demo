resource "random_string" "splunk_itsi_password" {
  length           = 12
  special          = false
  # override_special = "@£$"
}

resource "aws_instance" "splunk_itsi" {
  count                     = var.splunk_itsi_count
  ami                       = var.ami
  instance_type             = var.splunk_itsi_inst_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
    root_block_device {
    volume_size = 32
    volume_type = "gp3"
  }
  key_name                  = var.key_name
  vpc_security_group_ids    = [
    aws_security_group.itsi_sg.id
  ]

  tags = {
    Name = lower(join("_",[var.environment,element(var.splunk_itsi_ids, count.index)]))
  }

  provisioner "file" {
    source      = join("/",[var.splunk_itsi_files_local_path, var.splunk_itsi_license_filename])
    destination = "/tmp/${var.splunk_itsi_license_filename}}"
  }

  provisioner "file" {
    source      = join("/",[var.splunk_itsi_files_local_path, var.splunk_app_for_content_packs_filename])
    destination = "/tmp/${var.splunk_app_for_content_packs_filename}"
  }

  provisioner "file" {
    source      = join("/",[var.splunk_itsi_files_local_path, var.splunk_it_service_intelligence_filename])
    destination = "/tmp/${var.splunk_it_service_intelligence_filename}"
  }

  provisioner "file" {
    source      = join("/",[var.splunk_itsi_files_local_path, var.splunk_synthetic_monitoring_add_on_filename])
    destination = "/tmp/${var.splunk_synthetic_monitoring_add_on_filename}"
  }

  provisioner "file" {
    source      = join("/",[var.splunk_itsi_files_local_path, var.splunk_infrastructure_monitoring_add_on_filename])
    destination = "/tmp/${var.splunk_infrastructure_monitoring_add_on_filename}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_ITSI_Content_Pack.sh"
    destination = "/tmp/install_ITSI_Content_Pack.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/inputs.conf"
    destination = "/tmp/inputs.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      
    ## Create Splunk Ent Vars
      "SPLUNK_ITSI_PASSWORD=${random_string.splunk_itsi_password.result}",
      "SPLUNK_ITSI_VERSION=${var.splunk_itsi_version}",
      "SPLUNK_ITSI_FILENAME=${var.splunk_itsi_filename}",
      "SPLUNK_ITSI_LICENSE_FILE=${var.splunk_itsi_license_filename}",

    ## Write env vars to file (used for debugging)
      "echo $SPLUNK_ITSI_PASSWORD > /tmp/splunk_itsi_password",
      "echo $SPLUNK_ITSI_VERSION > /tmp/splunk_itsi_version",
      "echo $SPLUNK_ITSI_FILENAME > /tmp/splunk_itsi_filename",
      "echo $SPLUNK_ITSI_LICENSE_FILE > /tmp/splunk_itsi_license_file",

    ## Install Splunk + ITSI + O11y Content Pack
      "sudo chmod +x /tmp/install_ITSI_Content_Pack.sh",
      "sudo /tmp/install_ITSI_Content_Pack.sh $SPLUNK_ITSI_PASSWORD $SPLUNK_ITSI_VERSION $SPLUNK_ITSI_FILENAME $SPLUNK_ITSI_LICENSE_FILE",
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

output "splunk_itsi_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.splunk_itsi.*.tags.Name,
    aws_instance.splunk_itsi.*.public_ip,
  )
}

output "splunk_itsi_urls" {
  value =  formatlist(
    "%s%s:%s", 
    "http://",
    aws_instance.splunk_itsi.*.public_ip,
    "8000",
  )
}

output "splunk_itsi_password" {
  value = random_string.splunk_itsi_password.result
}
