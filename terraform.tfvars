# File should be referenced with  
# -var-file="variables.tfvars"

# Variables need to be defined first in the variables.tf file

# this should NOT be stored in a public source control system as it contains sensitive information

### AWS Variables ###
#profile = "geoff-sysops"
profile = "splnktf"
#region = "us-east-1"
region = "eu-west-1"
#vpc_id = "vpc-aced7fd6"
vpc_id = "vpc-1751ad6e"
#subnet_id = "subnet-00a8eb5c"
subnet_id = "subnet-ff076da5"
#ami = "ami-026c8acd92718196b"
ami = "ami-0701e7be9b2a77600"
key_name = "geoffh"
instance_type = "t2.micro"
smart_gateway_instance_type = "t2.small"

### Instance IPs ###
smart_gateway1_ip = "172.31.32.10"
smart_gateway2_ip = "172.31.32.20"
smart_gateway_ip = "172.31.32.30"
nginx1_ip = "172.31.33.10"
nginx2_ip = "172.31.33.20"
wordpress1_ip = "172.31.34.10"
wordpress2_ip = "172.31.34.20"
mysql1_ip = "172.31.35.10"
mysql2_ip = "172.31.35.20"
haproxy1_ip = "172.31.36.10"
haproxy2_ip = "172.31.36.20"
app-server1_ip = "172.31.37.10"
app-server2_ip = "172.31.37.20"

### SignalFX Variables ###
auth_token = "jgaxeLuct7RVQx7LxNu0HQ"
api_url = "https://api.eu0.signalfx.com"
realm = "eu0"
smart_gateway_cluster_name = "demo"
smart_gateway_version = "v2.1.9"
# smart_agent_version = "4.20.2-1" # Optional - If left blank, latest will be installed
smart_agent_version = "" # Optional - If left blank, latest will be installed
# traceEndpointUrl should be IP of Single Smart Gateway (172.31.32.30:8080), or IP of LB fronting Clustered Gateways (172.31.33.10:80)
# traceEndpointUrl = "http://172.31.32.30:8080/v1/trace"
traceEndpointUrl = "http://172.31.33.10:80/v1/trace"

