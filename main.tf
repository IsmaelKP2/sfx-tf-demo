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
  vpc_id = module.vpc.vpc_id
  # vpc_cidr = var.vpc_cidr
  vpc_cidr_block = var.vpc_cidr_block
}

module "vpc" {
  source = "./vpc"
  vpc_name = var.vpc_name
  vpc_cidr_block = var.vpc_cidr_block
  subnet_count = var.subnet_count
  subnet_cidrs = var.subnet_cidrs
  subnet_names = var.subnet_names
  subnet_availability_zones = var.subnet_availability_zones
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
  cluster_name = var.cluster_name
  smart_agent_version = var.smart_agent_version
  otelcol_version = var.otelcol_version
  ballast = var.ballast

  vpc_id = module.vpc.vpc_id
  vpc_cidr_block = var.vpc_cidr_block
  subnet_ids = module.vpc.subnet_ids
  
  key_name = var.key_name
  private_key_path = var.private_key_path
  instance_type = var.instance_type
  collector_instance_type = var.collector_instance_type
    
  sg_allow_egress_id = module.security_groups.sg_allow_egress_id
  sg_allow_ssh_id = module.security_groups.sg_allow_ssh_id
  sg_web_id = module.security_groups.sg_web_id
  sg_allow_all_id = module.security_groups.sg_allow_all_id
  sg_mysql_id = module.security_groups.sg_mysql_id
  sg_collectors_id = module.security_groups.sg_collectors_id

  collector_count = var.collector_count
  collector_ids = var.collector_ids
  haproxy_count = var.haproxy_count
  haproxy_ids = var.haproxy_ids
  mysql_count = var.mysql_count
  mysql_ids = var.mysql_ids
  wordpress_count = var.wordpress_count
  wordpress_ids = var.wordpress_ids
  app_server_count = var.app_server_count
  app_server_ids = var.app_server_ids
  #xxx _count = var.xxx _count
  #xxx _ids = var.xxx _ids
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}
output "Collectors" {
  value = module.instances.collector_details
}
output "HAProxies" {
  value = module.instances.haproxy_details
}
output "MySQL_Servers" {
  value = module.instances.mysql_details
}
output "WordPress_Servers" {
  value = module.instances.wordpress_details
}
output "App_Servers" {
  value = module.instances.app_server_details
}
output "collector_lb_dns" {
  value = module.instances.collector_lb_int_dns
}
