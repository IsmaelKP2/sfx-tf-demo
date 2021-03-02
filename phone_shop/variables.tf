### Phone Shop App Variables ###
## URL for the Java App - pulls it from the listed Git Repo
variable "java_app_url" {
  default = "https://github.com/hagen-p/SplunkLambdaAPM.git"
}

## Function Code URLs
variable "function_retailorder_url" {
  default = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderAPM/Lambda_Function.py"
}
variable "function_retailorderline_url" {
  default = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderLineAPM/Lambda_Function.py"
}
variable "function_retailorderprice_url" {
  default = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailOrderPriceAPM/index.js"
}
variable "function_retailorderdiscount_url" {
  default = "https://raw.githubusercontent.com/hagen-p/SplunkLambdaAPM/master/Lambdas/APM/RetailDiscountAPM/index.js"
}


### SignalFX Variables ###
variable "auth_token" {
  default = []
}
variable "environment" {
  default = []
}
variable "realm" {
  default = []
}
variable "cluster_name" {
  default = []
}
variable "smart_agent_version" {
  default = []
}


### AWS Variables ###
variable "instance_type" {
  default = []
}
variable "key_name" {
  default = []
}
variable "private_key_path"{
  default = []
}
variable "phone_shop_server_count" {
  default = {}
}
variable "phone_shop_server_ids" {
  default = []
}
variable "subnet_ids" {
  default = []
}
variable "sg_allow_egress_id" {
  default = {}
}
variable "sg_allow_ssh_id" {
  default = {}
}
variable "sg_web_id" {
  default = {}
}
variable "lambda_role_arn" {
  default = {}
}
variable "function_timeout" {
  default = 15
}
variable "region" {
  default = {}
}
variable "region_wrapper_python" {
  default = {}
}
variable "region_wrapper_nodejs" {
  default = {}
}

## AMI ##
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This is the owner id of Canonical who owns the official aws ubuntu images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
