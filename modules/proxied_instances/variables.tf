### AWS Variables ###
variable "region" {
  default = {}
}
variable "vpc_id" {
  default = []
}
variable "vpc_cidr_block" {
  default = []
}
variable "public_subnet_ids" {
  default = {}
}
variable "key_name" {
  default = []
}
variable "private_key_path"{
  default = []
}
variable "instance_type" {
  default = []
}
variable "ami" {
  default = {}
}

### SignalFX Variables ###
variable "access_token" {
  default = []
}
variable "api_url" {
  default = []
}
variable "realm" {
  default = []
}
variable "smart_agent_version" {
  default = []
}
variable "otelcol_version" {
  default = []
}
variable "ballast" {
  default = []
}
variable "environment" {
  default = []
}

variable "proxied_apache_web_count" {
  default = {}
}
variable "proxied_apache_web_ids" {
  default = []
}

variable "proxy_server_count" {
  default = {}
}
variable "proxy_server_ids" {
  default = []
}

variable "branch" {
  default = []
}