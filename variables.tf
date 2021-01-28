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
variable "vpc_name" {
  default = []
}
# variable "vpc_cidr" {
#   default = []
# }
variable "vpc_cidr_block" {
  default = []
}
variable "subnet_ids" {
  default = []
}
variable "subnet_availability_zones" {
  default = []
}
# variable "ami" {
#   default = []
# }
variable "key_name" {
  default = []
}
variable "private_key_path"{
  default = []
}
variable "instance_type" {
  default = []
}
variable "collector_instance_type" {
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
variable "sg_allow_all_id" {
  default = {}
}
variable "sg_mysql_id" {
  default = {}
}
variable "sg_collectors_id" {
  default = {}
}

## AMI ##
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This is the owner id of Canonical who owns the official aws ubuntu images

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

### Instance Count Variables ###
variable "subnet_count" {
  default = {}
}
variable "subnet_cidrs" {
  default = {}
}
variable "subnet_names" {
  default = {}
}

variable "collector_count" {
  default = {}
}
variable "collector_ids" {
  default = []
}

variable "haproxy_count" {
  default = {}
}
variable "haproxy_ids" {
  # type = list(string)
  default = []
}

variable "mysql_count" {
  default = {}
}
variable "mysql_ids" {
  # type = list(string)
  default = []
}

variable "wordpress_count" {
  default = {}
}
variable "wordpress_ids" {
  # type = list(string)
  default = []
}

variable "app_server_count" {
  default = {}
}
variable "app_server_ids" {
  # type = list(string)
  default = []
}

# variable "xxx _count" {
#   default = {}
# }
# variable "xxx _ids" {
#   type = list(string)
#   default = []
# }

### SOC Variables ###
variable "soc_integration_id" {
  default = {}
}
variable "soc_routing_key" {
  default = {}
}

### SignalFX Variables ###
variable "auth_token" {
  default = []
}
variable "api_url" {
  default = []
}
variable "realm" {
  default = []
}
variable "notification_email" {
  default = []
}
variable "cluster_name" {
  default = []
}
variable "smart_agent_version" {
  default = []
}
variable "environment" {
  default = []
}
variable "otelcol_version" {
  default = []
}
variable "ballast" {
  default = []
}

variable "message_body" {
  type = string

  default = <<-EOF
    {{#if anomalous}}
	    Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" triggered at {{timestamp}}.
    {{else}}
	    Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" cleared at {{timestamp}}.
    {{/if}}

    {{#if anomalous}}
      Triggering condition: {{{readableRule}}}
    {{/if}}

    {{#if anomalous}}
      Signal value: {{inputs.A.value}}
    {{else}}
      Current signal value: {{inputs.A.value}}
    {{/if}}

    {{#notEmpty dimensions}}
      Signal details: {{{dimensions}}}
    {{/notEmpty}}

    {{#if anomalous}}
      {{#if runbookUrl}}
        Runbook: {{{runbookUrl}}}
      {{/if}}
      {{#if tip}}
        Tip: {{{tip}}}
      {{/if}}
    {{/if}}
  EOF
}