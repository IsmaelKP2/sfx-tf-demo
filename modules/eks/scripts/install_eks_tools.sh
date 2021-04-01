#! /bin/bash
# Version 2.0

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo touch /etc/apt/sources.list.d/kubernetes.list
echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
sudo wget https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz
sudo tar -zxvf helm-v3.5.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm