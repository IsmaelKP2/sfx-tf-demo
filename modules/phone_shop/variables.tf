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
variable "access_token" {
  default = []
}
variable "environment" {
  default = []
}
variable "realm" {
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
variable "public_subnet_ids" {
  default = []
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
variable "vpc_id" {
  default = []
}
variable "vpc_cidr_block" {
  default = []
}
variable "region_wrapper_python" {
  default = {}
}
variable "region_wrapper_nodejs" {
  default = {}
}
variable "ami" {
  default = {}
}
