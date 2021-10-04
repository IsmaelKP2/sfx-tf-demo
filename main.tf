# AWS Auth Configuration
provider "aws" {
  region                  = lookup(var.aws_region, var.region)
  access_key              = var.aws_access_key_id
  secret_key              = var.aws_secret_access_key
}

provider "signalfx" {
  auth_token              = var.access_token
  api_url                 = var.api_url
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

module "dashboards" {
  source                  = "./modules/dashboards"
  count                   = var.dashboards_enabled ? 1 : 0
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
  det_prom_tags_id        = module.detectors.*.detector_promoting_tags_id
}

module "detectors" {
  source                  = "./modules/detectors"
  count                   = var.detectors_enabled ? 1 : 0
  notification_email      = var.notification_email
  soc_integration_id      = var.soc_integration_id
  soc_routing_key         = var.soc_routing_key
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
}

module "vpc" {
  source                  = "./modules/vpc"
  vpc_name                = var.environment
  vpc_cidr_block          = var.vpc_cidr_block
  subnet_count            = var.subnet_count
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
}

module "aws_ecs" {
  source                  = "./modules/aws_ecs"
  count                   = var.ecs_cluster_enabled ? 1 : 0
  region                  = lookup(var.aws_region, var.region)
  access_token            = var.access_token
  realm                   = var.realm
  environment             = var.environment
  ecs_agent_url           = var.ecs_agent_url
  ecs_app_port            = var.ecs_app_port
  ecs_health_check_path   = var.ecs_health_check_path
  ecs_app_image           = var.ecs_app_image
  ecs_container_name      = var.ecs_container_name
  ecs_fargate_cpu         = var.ecs_fargate_cpu
  ecs_fargate_memory      = var.ecs_fargate_memory
  ecs_app_count           = var.ecs_app_count
  ecs_az_count            = var.ecs_az_count
}

module "eks" {
  source                  = "./modules/eks"
  count                   = var.eks_cluster_enabled ? 1 : 0
  region                  = lookup(var.aws_region, var.region)
  environment             = var.environment
  smart_agent_version     = var.smart_agent_version
  access_token            = var.access_token
  realm                   = var.realm
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr_block          = var.vpc_cidr_block
  public_subnet_ids       = module.vpc.public_subnet_ids
  aws_access_key_id       = var.aws_access_key_id
  aws_secret_access_key   = var.aws_secret_access_key
  instance_type           = var.instance_type
  ami                     = data.aws_ami.latest-ubuntu.id
  key_name                = var.key_name
  private_key_path        = var.private_key_path
  eks_cluster_name        = join("-",[var.environment,"eks"])
}

module "eks_fargate" {
  source                    = "./modules/eks_fargate"
  count                     = var.eks_fargate_cluster_enabled ? 1 : 0
  region                    = lookup(var.aws_region, var.region)
  environment               = var.environment
  smart_agent_version       = var.smart_agent_version
  access_token              = var.access_token
  realm                     = var.realm
  eks_fargate_cluster_name  = join("-",[var.environment,"eks-fargate"])
}

module "phone_shop" {
  source                  = "./modules/phone_shop"
  count                   = var.phone_shop_enabled ? 1 : 0
  region_wrapper_python   = lookup(var.region_wrapper_python, var.region)
  region_wrapper_nodejs   = lookup(var.region_wrapper_nodejs, var.region)
  access_token            = var.access_token
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
  access_token            = var.access_token
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
  access_token            = var.access_token
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
  ms_sql_instance_type    = var.ms_sql_instance_type
  ami                     = data.aws_ami.latest-ubuntu.id
  ms_sql_ami              = data.aws_ami.ms-sql-server.id
  collector_count         = var.collector_count
  collector_ids           = var.collector_ids
  haproxy_count           = var.haproxy_count
  haproxy_ids             = var.haproxy_ids
  mysql_count             = var.mysql_count
  mysql_ids               = var.mysql_ids
  ms_sql_count            = var.ms_sql_count
  ms_sql_ids              = var.ms_sql_ids
  apache_web_count        = var.apache_web_count
  apache_web_ids          = var.apache_web_ids
  splunk_ent_count        = var.splunk_ent_count
  splunk_ent_ids          = var.splunk_ent_ids
  splunk_ent_version      = var.splunk_ent_version
  splunk_ent_filename     = var.splunk_ent_filename
  splunk_ent_inst_type    = var.splunk_ent_inst_type
}

### Instances Outputs ###
output "OTEL_Gateway_Servers" {
  value = var.instances_enabled ? module.instances.*.collector_details : null
}
output "HAProxy_Servers" {
  value = var.instances_enabled ? module.instances.*.haproxy_details : null
}
output "MySQL_Servers" {
  value = var.instances_enabled ? module.instances.*.mysql_details : null
}
output "MS_SQL_Servers" {
  value = var.instances_enabled ? module.instances.*.ms_sql_details : null
}
output "Apache_Web_Servers" {
  value = var.instances_enabled ? module.instances.*.apache_web_details : null
}
output "collector_lb_dns" {
  value = var.instances_enabled ? module.instances.*.collector_lb_int_dns : null
}
output "SQS_Test_Server" {
  value = var.lambda_sqs_dynamodb_enabled ? module.lambda_sqs_dynamodb.*.sqs_test_server_details : null
}

output "MS_SQL_Administrator_Password"{
  value = var.instances_enabled ? module.instances.*.Administrator_Password : null
}


### Phone Shop Outputs ###
output "Phone_Shop_Server" {
  value = var.phone_shop_enabled ? module.phone_shop.*.phone_shop_server_details : null
}

### ECS Outputs ###
output "ECS_ALB_hostname" {
  value = var.ecs_cluster_enabled ? module.aws_ecs.*.ecs_alb_hostname : null
}

### Splunk Enterprise Outputs ###
output "Splunk_Enterprise_Server" {
  value = var.instances_enabled ? module.instances.*.splunk_ent_details : null
}
output "splunk_password" {
  value = var.instances_enabled ? module.instances.*.splunk_password : null
  # sensitive = true
}
output "splunk_url" {
  value = var.instances_enabled ? module.instances.*.splunk_ent_urls : null
}


### Detector Outputs
output "detector_promoting_tags_id" {
  value = var.detectors_enabled ? module.detectors.*.detector_promoting_tags_id : null
}

### EKS Outputs ###
# output "eks_cluster_endpoint" {
#   value = var.eks_cluster_enabled ? module.eks.*.eks_cluster_endpoint : null
# }
output "eks_admin_server" {
  value = var.eks_cluster_enabled ? module.eks.*.eks_admin_server_details : null
}
