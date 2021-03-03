# AWS Auth Configuration
provider "aws" {
  # profile    = var.profile
  region     = lookup(var.aws_region, var.region)
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# SignalFx Provider
provider "signalfx" {
  auth_token = var.auth_token
  api_url = var.api_url
}

module "dashboards" {
  source           = "./dashboards"
  count            = var.dashboards_enabled ? 1 : 0
  region           = lookup(var.aws_region, var.region)
}

module "detectors" {
  source             = "./modules/detectors"
  count              = var.detectors_enabled ? 1 : 0
  notification_email = var.notification_email
  soc_integration_id = var.soc_integration_id
  soc_routing_key    = var.soc_routing_key
  region             = lookup(var.aws_region, var.region)
}

# module "iam_roles" {
#   source = "./iam_roles"
#   region           = lookup(var.aws_region, var.region)
# }

module "security_groups" {
  source           = "./modules/security_groups"
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = var.vpc_cidr_block
  region           = lookup(var.aws_region, var.region)
}

module "vpc" {
  source = "./vpc"
  vpc_name                  = var.vpc_name
  vpc_cidr_block            = var.vpc_cidr_block
  subnet_count              = var.subnet_count
  subnet_cidrs              = var.subnet_cidrs
  subnet_names              = var.subnet_names
  subnet_availability_zones = var.subnet_availability_zones
  region                    = lookup(var.aws_region, var.region)
}

module "phone_shop" {
  source                  = "./modules/phone_shop"
  count                   = var.phone_shop_enabled ? 1 : 0
  region_wrapper_python   = lookup(var.region_wrapper_python, var.region)
  region_wrapper_nodejs   = lookup(var.region_wrapper_nodejs, var.region)
  auth_token              = var.auth_token
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
  realm                   = var.realm
  cluster_name            = var.cluster_name
  smart_agent_version     = var.smart_agent_version
  instance_type           = var.instance_type
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  subnet_ids              = module.vpc.subnet_ids
  sg_allow_egress_id      = module.security_groups.sg_allow_egress_id
  sg_allow_ssh_id         = module.security_groups.sg_allow_ssh_id
  sg_web_id               = module.security_groups.sg_web_id
  ami                     = data.aws_ami.latest-ubuntu.id
}

module "lambda_sqs_dynamodb" {
  source                  = "./modules/lambda_sqs_dynamodb"
  count                   = var.lambda_sqs_dynamodb_enabled ? 1 : 0
  region_wrapper_python   = lookup(var.region_wrapper_python, var.region)
  auth_token              = var.auth_token
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
  realm                   = var.realm
  cluster_name            = var.cluster_name
  smart_agent_version     = var.smart_agent_version
  aws_access_key_id       = var.aws_access_key_id
  aws_secret_access_key   = var.aws_secret_access_key
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  instance_type           = var.instance_type
  subnet_ids              = module.vpc.subnet_ids
  sg_allow_egress_id      = module.security_groups.sg_allow_egress_id
  sg_allow_ssh_id         = module.security_groups.sg_allow_ssh_id
  ami                     = data.aws_ami.latest-ubuntu.id
}

module "instances" {
  source                  = "./instances"
  count                   = var.instances_enabled ? 1 : 0
  auth_token              = var.auth_token
  api_url                 = var.api_url
  realm                   = var.realm
  cluster_name            = var.cluster_name
  smart_agent_version     = var.smart_agent_version
  otelcol_version         = var.otelcol_version
  ballast                 = var.ballast
  environment             = var.environment
  region                  = lookup(var.aws_region, var.region)
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  subnet_ids              = module.vpc.subnet_ids
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  instance_type           = var.instance_type
  collector_instance_type = var.collector_instance_type

  sg_allow_egress_id      = module.security_groups.sg_allow_egress_id
  sg_allow_ssh_id         = module.security_groups.sg_allow_ssh_id
  sg_web_id               = module.security_groups.sg_web_id
  sg_allow_all_id         = module.security_groups.sg_allow_all_id
  sg_mysql_id             = module.security_groups.sg_mysql_id
  sg_collectors_id        = module.security_groups.sg_collectors_id
 
  collector_count         = var.collector_count
  collector_ids           = var.collector_ids
  haproxy_count           = var.haproxy_count
  haproxy_ids             = var.haproxy_ids
  mysql_count             = var.mysql_count
  mysql_ids               = var.mysql_ids
  wordpress_count         = var.wordpress_count
  wordpress_ids           = var.wordpress_ids
}

output "Collectors" {
  value = var.instances_enabled ? module.instances.*.collector_details : null
}
output "HAProxies" {
  value = var.instances_enabled ? module.instances.*.haproxy_details : null
}
output "MySQL_Servers" {
  value = var.instances_enabled ? module.instances.*.mysql_details : null
}
output "WordPress_Servers" {
  value = var.instances_enabled ? module.instances.*.wordpress_details : null
}
# output "App_Servers" {
#   value = var.instances_enabled ? module.instances.*.app_server_details : null
# }
output "collector_lb_dns" {
  value = var.instances_enabled ? module.instances.*.collector_lb_int_dns : null
}

output "SQS_Test_Server" {
  value = var.lambda_sqs_dynamodb_enabled ? module.lambda_sqs_dynamodb.*.sqs_test_server_details : null
}

output "Phone_Shop_Server" {
  value = var.phone_shop_enabled ? module.phone_shop.*.phone_shop_server_details : null
}