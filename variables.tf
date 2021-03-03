## Enable/Disable Modules - Values are set in quantity.auto.tfvars ###
variable "instances_enabled" {
  default = []
}
variable "phone_shop_enabled" {
  default = []
}
variable "lambda_sqs_dynamodb_enabled" {
  default = []
}
variable "dashboards_enabled" {
  default = []
}
variable "detectors_enabled" {
  default = []
}


### AWS Variables ###
variable "profile" {
  default = []
}
variable "aws_access_key_id" {
  default = []
}
variable "aws_secret_access_key" {
  default = []
}
variable "vpc_id" {
  default = []
}
variable "vpc_name" {
  default = []
}
variable "vpc_cidr_block" {
  default = []
}
variable "subnet_ids" {
  default = []
}
variable "subnet_availability_zones" {
  default = []
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
variable "aws_api_gateway_deployment_retailorder_invoke_url" {
  default = {}
}

## AMI ##
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This is the owner id of Canonical who owns the official aws ubuntu images

  filter {
    name   = "name"
    # values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
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
  default = []
}

variable "mysql_count" {
  default = {}
}
variable "mysql_ids" {
  default = []
}

variable "wordpress_count" {
  default = {}
}
variable "wordpress_ids" {
  default = []
}

# variable "xxx _count" {
#   default = {}
# }
# variable "xxx _ids" {
#   type = list(string)
#   default = []
# }

variable "region" {
  description = "Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )"
}

variable "aws_region" {
  description = "Provide the desired region"
    default = {
      "1" = "eu-west-1"
      "2" = "eu-west-3"
      "3" = "eu-central-1"
      "4" = "us-east-1"
      "5" = "us-east-2"
      "6" = "us-west-1"
      "7" = "us-west-2"
      "8" = "ap-southeast-1"
      "9" = "ap-southeast-2"
      "10" = "sa-east-1"
    }
}

## List available at https://github.com/signalfx/lambda-layer-versions/blob/master/python/PYTHON.md ##
variable "region_wrapper_python" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "3" = "arn:aws:lambda:eu-central-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "4" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "5" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "6" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "7" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "8" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "9" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-python-wrapper:11"
    "10" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-python-wrapper:11"  
  }
}

## List available at https://github.com/signalfx/lambda-layer-versions/blob/master/node/NODE.md ##
variable "region_wrapper_nodejs" {
  default = {
    "1" = "arn:aws:lambda:eu-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "2" = "arn:aws:lambda:eu-west-3:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "3" = "arn:aws:lambda:eu-central-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:19"
    "4" = "arn:aws:lambda:us-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "5" = "arn:aws:lambda:us-east-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "6" = "arn:aws:lambda:us-west-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "7" = "arn:aws:lambda:us-west-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:18"
    "8" = "arn:aws:lambda:ap-southeast-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "9" = "arn:aws:lambda:ap-southeast-2:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"
    "10" = "arn:aws:lambda:sa-east-1:254067382080:layer:signalfx-lambda-nodejs-wrapper:17"  
  }
}


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

# variable "message_body" {
#   type = string

#   default = <<-EOF
#     {{#if anomalous}}
# 	    Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" triggered at {{timestamp}}.
#     {{else}}
# 	    Rule "{{{ruleName}}}" in detector "{{{detectorName}}}" cleared at {{timestamp}}.
#     {{/if}}

#     {{#if anomalous}}
#       Triggering condition: {{{readableRule}}}
#     {{/if}}

#     {{#if anomalous}}
#       Signal value: {{inputs.A.value}}
#     {{else}}
#       Current signal value: {{inputs.A.value}}
#     {{/if}}

#     {{#notEmpty dimensions}}
#       Signal details: {{{dimensions}}}
#     {{/notEmpty}}

#     {{#if anomalous}}
#       {{#if runbookUrl}}
#         Runbook: {{{runbookUrl}}}
#       {{/if}}
#       {{#if tip}}
#         Tip: {{{tip}}}
#       {{/if}}
#     {{/if}}
#   EOF
# }
