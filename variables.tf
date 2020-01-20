#File is sym linked to sub-folders

### AWS Variables ###
variable "profile" {
  default = []
}
variable "region" {
  default = []
}
variable "vpc_id" {
  default = []
}
variable "subnet_id" {
  default = []
}
variable "ami" {
  default = []
}
variable "key_name" {
  default = []
}
variable "instance_type" {
  default = []
}
variable "smart_gateway_instance_type" {
  default = []
}

variable "allow_egress_id" {
  default = {}
}
variable "allow_ssh_id" {
  default = {}
}
variable "allow_web_id" {
  default = {}
}
variable "allow_all_id" {
  default = {}
}
variable "allow_mysql_id" {
  default = {}
}

### Instance IP Addresses ###
variable "smart_gateway1_ip" {
  default = {}
}
variable "smart_gateway2_ip" {
  default = {}
}
variable "nginx1_ip" {
  default = {}
}
variable "nginx2_ip" {
  default = {}
}
variable "wordpress1_ip" {
  default = {}
}
variable "wordpress2_ip" {
  default = {}
}
variable "mysql1_ip" {
  default = {}
}
variable "mysql2_ip" {
  default = {}
}
variable "haproxy1_ip" {
  default = {}
}
variable "haproxy2_ip" {
  default = {}
}
variable "app-server1_ip" {
  default = {}
}
variable "app-server2_ip" {
  default = {}
}

### SignalFX Authentication Variables ###
variable "auth_token" {
  default = []
}
variable "api_url" {
  default = []
}