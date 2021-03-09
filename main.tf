# AWS Auth Configuration
provider "aws" {
  region     = lookup(var.aws_region, var.region)
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# SignalFx Provider
provider "signalfx" {
  auth_token = var.auth_token
  api_url    = var.api_url
}

module "dashboards" {
  source           = "./modules/dashboards"
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

# module "security_groups" {
#   source           = "./modules/security_groups"
#   vpc_id           = module.vpc.vpc_id
#   vpc_cidr_block   = var.vpc_cidr_block
#   region           = lookup(var.aws_region, var.region)
# }

module "vpc" {
  source                    = "./modules/vpc"
  vpc_name                  = var.vpc_name
  vpc_cidr_block            = var.vpc_cidr_block
  subnet_count              = var.subnet_count
  region                    = lookup(var.aws_region, var.region)
}

module "aws_ecs" {
  source                  = "./modules/aws_ecs"
  count                   = var.ecs_cluster_enabled ? 1 : 0
  region                  = lookup(var.aws_region, var.region)
  ecs_app_port            = var.ecs_app_port
  ecs_health_check_path   = var.ecs_health_check_path
  ecs_app_image           = var.ecs_app_image
  ecs_container_name      = var.ecs_container_name
  ecs_fargate_cpu         = var.ecs_fargate_cpu
  ecs_fargate_memory      = var.ecs_fargate_memory
  ecs_app_count           = var.ecs_app_count
  ecs_az_count            = var.ecs_az_count
}

module "phone_shop" {
  source                  = "./modules/phone_shop"
  count                   = var.phone_shop_enabled ? 1 : 0
  region_wrapper_python   = lookup(var.region_wrapper_python, var.region)
  region_wrapper_nodejs   = lookup(var.region_wrapper_nodejs, var.region)
  auth_token              = var.auth_token
  region                  = lookup(var.aws_region, var.region)
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  environment             = var.environment
  realm                   = var.realm
  smart_agent_version     = var.smart_agent_version
  instance_type           = var.instance_type
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  public_subnet_ids       = module.vpc.public_subnet_ids
  ami                     = data.aws_ami.latest-ubuntu.id
}

module "lambda_sqs_dynamodb" {
  source                  = "./modules/lambda_sqs_dynamodb"
  count                   = var.lambda_sqs_dynamodb_enabled ? 1 : 0
  region_wrapper_python   = lookup(var.region_wrapper_python, var.region)
  auth_token              = var.auth_token
  region                  = lookup(var.aws_region, var.region)
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  environment             = var.environment
  realm                   = var.realm
  smart_agent_version     = var.smart_agent_version
  aws_access_key_id       = var.aws_access_key_id
  aws_secret_access_key   = var.aws_secret_access_key
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  instance_type           = var.instance_type
  public_subnet_ids       = module.vpc.public_subnet_ids
  ami                     = data.aws_ami.latest-ubuntu.id
}

module "instances" {
  source                  = "./modules/instances"
  count                   = var.instances_enabled ? 1 : 0
  auth_token              = var.auth_token
  api_url                 = var.api_url
  realm                   = var.realm
  smart_agent_version     = var.smart_agent_version
  otelcol_version         = var.otelcol_version
  ballast                 = var.ballast
  environment             = var.environment
  region                  = lookup(var.aws_region, var.region)
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  public_subnet_ids       = module.vpc.public_subnet_ids
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  instance_type           = var.instance_type
  collector_instance_type = var.collector_instance_type
  ami                     = data.aws_ami.latest-ubuntu.id
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
output "collector_lb_dns" {
  value = var.instances_enabled ? module.instances.*.collector_lb_int_dns : null
}

output "SQS_Test_Server" {
  value = var.lambda_sqs_dynamodb_enabled ? module.lambda_sqs_dynamodb.*.sqs_test_server_details : null
}

output "Phone_Shop_Server" {
  value = var.phone_shop_enabled ? module.phone_shop.*.phone_shop_server_details : null
}

output "ECS_ALB_hostname" {
  value = var.ecs_cluster_enabled ? module.aws_ecs.*.ecs_alb_hostname : null
}
