### Note the instances will be deployed into the VPC Subnet matching their
### 'count' value, so as there are only 3 subnets within the VPC
### you can deploy no more than 3 of any one instance type.

subnet_count = "3"
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
subnet_availability_zones = [
    "eu-west-1a",
    "eu-west-1b",
    "eu-west-1c"
    ]

collector_count = "2"
collector_ids = [
    "Collector1",
    "Collector2",
    "Collector3"
    ]

haproxy_count = "2"
haproxy_ids = [
    "haproxy1",
    "haprpxy2"
    ]

mysql_count = "1"
mysql_ids = [
    "mysql1",
    "mysql2"
    ]

wordpress_count = "1"
wordpress_ids = [
    "wordpress1",
    "wordpress2"
    ]

app_server_count = "1"
app_server_ids = [
    "app_server1",
    "app_server2"
    ]