### Note the instances will be deployed into the VPC Subnet matching their
### 'count' value, so as there are only 3 subnets within the VPC
### you can deploy no more than 3 of any one instance type.

### This file controls how many of each type of instance are deployed, and 
### also allocates their hostnames.

### It also controls the subnet settings created by the VPC module


### Enable / Disable Modules
instances_enabled = true
phone_shop_enabled = true
lambda_sqs_dynamodb_enabled = true
dashboards_enabled = true
detectors_enabled = true


subnet_count = "3" # max 3
### Subnet cidrs need to be from the vpc_cidr_block detailed in terraform.tfvars
### Can these use variable values so they can be moved to terraform.tfvars
subnet_cidrs = [
    "172.32.0.0/20",
    "172.32.16.0/20",
    "172.32.32.0/20"
    ]
subnet_names = [
    "subnet1",
    "subnet2",
    "subnet3"
    ]
### Subnets need to belong to the AWS Region specified in 'terraform.tfvars'
### Need to automate this via variables.tf lookup
subnet_availability_zones = [
    "eu-west-3a",
    "eu-west-3b",
    "eu-west-3c"
    ]

collector_count = "1" # max 3
collector_ids = [
    "Collector1",
    "Collector2",
    "Collector3"
    ]

haproxy_count = "0" # max 3
haproxy_ids = [
    "haproxy1",
    "haproxy2",
    "haproxy3"
    ]

mysql_count = "0" # max 3
mysql_ids = [
    "mysql1",
    "mysql2",
    "mysql3"
    ]

wordpress_count = "0" # max 3
wordpress_ids = [
    "wordpress1",
    "wordpress2",
    "wordpress3"
    ]

# app_server_count = "0" # max 3
# app_server_ids = [
#     "app_server1",
#     "app_server2",
#     "app_server3"
#     ]