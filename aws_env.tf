# AWS Auth Configuration
provider "aws" {
  profile    = "${var.profile}"
  region     =  "${var.region}"
}

data "aws_vpc" "default" {
  id = "${var.vpc_id}"
}

