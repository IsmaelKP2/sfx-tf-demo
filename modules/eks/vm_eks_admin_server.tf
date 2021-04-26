resource "aws_instance" "eks_admin_server" {
  ami                       = var.ami
  instance_type             = var.instance_type
  subnet_id                 = element(var.public_subnet_ids, 0)
  key_name                  = var.key_name
  vpc_security_group_ids    = [
    aws_security_group.eks_admin_server.id,
  ]
 
  tags = {
    # Name = "eks_admin"
    Name = "${var.environment}_eks_admin"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_sfx_agent.sh"
    destination = "/tmp/install_sfx_agent.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_aws_config.sh"
    destination = "/tmp/generate_aws_config.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/generate_values.sh"
    destination = "/tmp/generate_values.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_eks_tools.sh"
    destination = "/tmp/install_eks_tools.sh"
  }

  provisioner "file" {
    source      = "${path.module}/config_files/deployment.yaml"
    destination = "/home/ubuntu/deployment.yaml"
  }

  depends_on = [aws_eks_cluster.demo]

  # provisioner "file" {
  #   source      = "${path.module}/scripts/update_sfx_environment.sh"
  #   destination = "/tmp/update_sfx_environment.sh"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/scripts/locustfile.py"
  #   destination = "/tmp/locustfile.py"
  # }

  # provisioner "file" {
  #   source      = "${path.module}/config_files/locust.service"
  #   destination = "/tmp/locust.service"
  # }

# remote-exec
  provisioner "remote-exec" {
    inline = [
    ## Set Hostname
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      
    ## Update
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

    ## Install SignalFx
      "TOKEN=${var.access_token}",
      "REALM=${var.realm}",
      "HOSTNAME=${self.tags.Name}",
      "AGENTVERSION=${var.smart_agent_version}",
      "ENVIRONMENT=${var.environment}",

      "sudo chmod +x /tmp/install_sfx_agent.sh",
      "sudo /tmp/install_sfx_agent.sh $TOKEN $REALM $AGENTVERSION",
      
      # "sudo chmod +x /tmp/update_sfx_environment.sh",
      # "sudo /tmp/update_sfx_environment.sh $ENVIRONMENT",

    ## Setup AWS Cli
      "sudo curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o /tmp/awscliv2.zip",
      "sudo apt install unzip -y",
      "unzip /tmp/awscliv2.zip",
      "sudo ~/aws/install",
      "sudo chmod +x /tmp/generate_aws_config.sh",
      "AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      "REGION=${var.region}",
      "/tmp/generate_aws_config.sh $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $REGION",

    ## Install EKS Tools
      "sudo chmod +x /tmp/install_eks_tools.sh",
      "/tmp/install_eks_tools.sh",
      "ENVIRONMENT=${var.environment}",
      "sudo chmod +x /tmp/generate_values.sh",
      "/tmp/generate_values.sh $ENVIRONMENT",

    ## Deploy SFX Agent into Cluster using Helm
      "AWS_DEFAULT_REGION=${var.region}",
      "AWS_DEFAULT_OUTPUT=json",
      "EKS_CLUSTER_NAME=${var.eks_cluster_name}",
      "eksctl utils write-kubeconfig --cluster=$EKS_CLUSTER_NAME",
      "eksctl get clusters",
      "aws eks update-kubeconfig --name $EKS_CLUSTER_NAME",
      "helm repo add signalfx https://dl.signalfx.com/helm-repo",
      "helm repo update",
      "helm install --set signalFxAccessToken=$TOKEN --set clusterName=$EKS_CLUSTER_NAME --set signalFxRealm=$REALM --set kubeletAPI.url=https://localhost:10250 --set traceEndpointUrl=https://ingest.$REALM.signalfx.com/v2/trace signalfx-agent signalfx/signalfx-agent -f /home/ubuntu/values.yaml",

    ## Deploy Hot Rod
      "kubectl apply -f /home/ubuntu/deployment.yaml",
      
    ## Write env vars to file (used for debugging)
      "echo $AWS_ACCESS_KEY_ID > /tmp/aws_access_key_id",
      "echo $AWS_SECRET_ACCESS_KEY > /tmp/aws_secret_access_key",
      "echo $REGION > /tmp/region",
      "echo $EKS_CLUSTER_NAME > /tmp/eks_cluster_name",
      "echo $TOKEN > /tmp/access_token",
      "echo $REALM > /tmp/realm",
      "echo $ENVIRONMENT > /tmp/environment",

    ## Configure motd
      "sudo curl -s https://raw.githubusercontent.com/signalfx/observability-workshop/master/cloud-init/motd -o /etc/motd",
      "sudo chmod -x /etc/update-motd.d/*",

    ## Add Cluster Details to S3
      # "BUCKET=${aws_s3_bucket.eksurl.id}",
      # "kubectl get svc hotrod | grep hotrod | tr -s ' ' | cut -d ' ' -f 4 | aws s3 cp - s3://$BUCKET/eksurl.txt",
    ]
  }

  # provisioner "remote-exec" {
  #   when = destroy
  #   on_failure = continue
  #   inline = [
  #     "kubectl delete -f deployment.yaml",
  #   ]
  # }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "eks_admin_server_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.eks_admin_server.*.tags.Name,
    aws_instance.eks_admin_server.*.public_ip,
  )
}