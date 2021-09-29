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
variable "region" {
  default = {}
}
variable "aws_access_key_id" {
  default = []
}
variable "aws_secret_access_key" {
  default = []
}
variable "eks_fargate_cluster_name" {
  default = {}
}
variable "fargate_namespace" {
  default = "fargate-node"
}
variable "eks_fargate_node_group_instance_types" {
  default = "t2.micro"
}




variable "eks_fargate_vpc_cidr" {
    default = "10.0.0.0/16"
}
variable "eks_fargate_public_cidr" {
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}
variable "eks_fargate_private_cidr" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
variable "cidr_block_internet_gw" {
    default = "0.0.0.0/0"
}
variable "cidr_block_nat_gw" {
    default = "0.0.0.0/0"
}

