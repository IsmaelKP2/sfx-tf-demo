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
variable "ami" {
  default = {}
}