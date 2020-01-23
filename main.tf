# AWS Auth Configuration
provider "aws" {
  profile    = var.profile
  region     = var.region
}

# SignalFx Provider
provider "signalfx" {
  auth_token = var.auth_token
  api_url = var.api_url
}

module "security_groups" {
  source = "./security_groups"

  vpc_id = var.vpc_id
}

module "dashboards" {
  source = "./dashboards"
}

module "detectors" {
  source = "./detectors"
}

module "instances" {
  source = "./instances"

  auth_token = var.auth_token
  api_url = var.api_url
  realm = var.realm
  smart_gateway_cluster_name = var.smart_gateway_cluster_name
  smart_gateway_version = var.smart_gateway_version
  smart_agent_version = var.smart_agent_version

  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
  ami = var.ami
  key_name = var.key_name
  instance_type = var.instance_type
  smart_gateway_instance_type = var.smart_gateway_instance_type
  
  allow_egress_id = module.security_groups.allow_egress_id
  allow_ssh_id = module.security_groups.allow_ssh_id
  allow_web_id = module.security_groups.allow_web_id
  allow_all_id = module.security_groups.allow_all_id
  allow_mysql_id = module.security_groups.allow_mysql_id
  
  app-server1_ip = var.app-server1_ip
  app-server2_ip = var.app-server2_ip
  wordpress1_ip = var.wordpress1_ip
  wordpress2_ip = var.wordpress2_ip
  nginx1_ip = var.nginx1_ip
  nginx2_ip = var.nginx2_ip
  smart_gateway1_ip = var.smart_gateway1_ip
  smart_gateway2_ip = var.smart_gateway2_ip
  smart_gateway_ip = var.smart_gateway_ip
  mysql1_ip = var.mysql1_ip
  mysql2_ip = var.mysql2_ip
  haproxy1_ip = var.haproxy1_ip
  haproxy2_ip = var.haproxy2_ip
}