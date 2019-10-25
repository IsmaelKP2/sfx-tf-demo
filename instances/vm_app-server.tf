data "template_cloudinit_config" "user_data_app_server" {
  gzip          = true
  base64_encode = true

  # get install_sfx_agent.sh
  part {
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/scripts/install_sfx_agent.sh")}"
  }

# data "aws_instance" "smart_gateway" {
#   instance_id = "i-instanceid"

#   filter {
#     name   = "tag:Name"
#     values = ["Smart-Gateway1"]
#   }
# }

### This is not working yet https://wiki.christophchamp.com/index.php?title=Terraform#Template_provider ####
# data "template_file" "smart-gateway-template" {
#   template = "${file("${path.module}/templates/smart-gateway.tpl")}"
#   vars {
#     smart-gateway-eip = "${aws_instance.smart-gateway.public_ip}"
#   }
}

resource "aws_instance" "app-server" {
  count         = "${var.app_server_count}"
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name      = "geoffh"
  user_data     = "${data.template_cloudinit_config.user_data_app_server.rendered}"
  vpc_security_group_ids  = [
    "${data.terraform_remote_state.security_groups.outputs.allow_egress_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_tls_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_http_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_ssh_id}",
    "${data.terraform_remote_state.security_groups.outputs.allow_sfx_mon_id}",
    ]

  tags = {
    Name = "App-Server${count.index + 1}"
  }

  provisioner "file" {
    source      = "agents/agent_app-server.yaml"
    destination = "/tmp/agent.yaml"
  }
  




  # provisioner "file" {
  #   # content     = data.state.smart_gateway_private_ip
  #   content       = user_data.private_ip.smart-gateway
  #   # content       = data.aws_instance.smart-gateway.*.private_ip
  #   # content       = data.private_ip.aws_instance.smart-gateway.*.private_ip
  #   destination   = "/tmp/smart_gateway_private_ip"
  # }

  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/signalfx/agent.yaml ]; do sleep 2; done",
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/agent.yaml /etc/signalfx/agent.yaml",
      "sudo chown root:root /etc/signalfx/agent.yaml",
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
