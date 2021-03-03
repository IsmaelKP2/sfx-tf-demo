
# variable "function_lamdba_sqs_dynamodb_url" {
#   default = "https://raw.githubusercontent.com/linuxacademy/content-lambda-boto3/master/Triggering-Lambda-from-SQS/lambda_function.py"
# }


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
variable "aws_access_key_id" {
  default = []
}
variable "aws_secret_access_key" {
  default = []
}
variable "instance_type" {
  default = []
}
variable "key_name" {
  default = []
}
variable "private_key_path"{
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
variable "ami" {
  default = {}
}