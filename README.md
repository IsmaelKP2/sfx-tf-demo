# Splunk Observability Terraform Demo

## Introduction

This is a collection of Terraform Modules which can be used to deploy a test environment into a new AWS VPC.  The purpose is to enable the user to deploy some typical AWS resources, and at the same time, deploy Splunk IMT and APM to monitor the deployed resources. The aim is to provide fully configured working examples to supplement the Splunk documentation, and accelerate adoption time.

## Requirements

To use this repo, you need an active AWS account. Where possible resources that qualify for the free tier are used by default to enable deployment to trial accounts with minimal costs.

You will also need a Splunk Infrastructure Monitoring Account. Some modules leverage the Splunk APM features so ideally you will also have APM enabled on your Splunk environment.  Note if you using a Trial Account, APM is not typically enabled.

Optionally a Splunk On-Call account with an active integration with Splunk IM/APM so that the full alerting flow can be tested.

## Setup

After cloning the repo, you need to generate and configure a terraform.tfvars file that will be unique to you and will not be synced back to the repo (if you are contributing to this repo).

Copy the included terraform.tfvars.example file to terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the contents of terraform.tfvars replacing any value contained within <> to suit your environment.  Note some values have been pre-populated with typical values, please review every setting and update as appropriate.

### Contents of terraform.tfvars.example

```yaml
### AWS Variables ###
#region = "<REGION>"
vpc_name = "tfdemo"
vpc_cidr_block = "172.32.0.0/16"
key_name = "<NAME>"
private_key_path = "~/.ssh/id_rsa"
instance_type = "t2.micro"
aws_access_key_id = "<ACCCESS_KEY_ID>>"
aws_secret_access_key = "<SECRET_ACCESS_KEY>>"

### SOC Variables ###
soc_integration_id = "<ID>"
soc_routing_key = "<ROUTING_KEY>"

### Splunk Variables ###
auth_token = "<AUTH_TOKEN>"
api_url = "https://api.<REALM>.signalfx.com"
realm = "<REALM>"
environment = "<ENVIRONMENT>"
notification_email = "<EMAIL>"

smart_agent_version = "" # Optional - If left blank, latest will be installed - example value would be "5.7.1-1"

### Collector Variables ###
### https://quay.io/repository/signalfx/splunk-otel-collector?tab=tags
otelcol_version = "0.3.0"
ballast = "683"
collector_instance_type = "t2.micro"
```

#### AWS Variables

This section details the parameters required by AWS such as Region (see below for more info on this), VPC settings, SSH Auth Key, and authentication to your AWS account.

**Region**
When you run the deployment terraform will prompt you for a realm, however if you enable the setting here, and populate it with a numerical value representing your preferred AWS Region, it will save you having to enter a value on each run. The setttings for this are controlled via variables.tf, but the valid options are:

..*1:eu-west-1
..*2:eu-west-3
..*3:eu-central-1
..*4:us-east-1
..*5:us-east-2
..*6:us-west-1
..*7:us-west-2
..*8:ap-southeast-1
..*9:ap-southeast-2
..*10:sa-east-1

#### SOC Variables

Settings used by the Splunk On-Call Integration to create Incidents from the Alerts generated by Splunk IM/APM

#### Splunk Variables

Settings used by Splunk IM/APM for authentication, notifications and APM Environment.  An example of an Environment value would be "TF Demo".

Optinally you can specify a specific version for the smart_agent, but if left blank the latest will be used, which is the recommended option.

## Modules

There are a number of core modules which are always deployed such as VPC and Security Groups, but the following modules can be enabled/disabled by updating the settings in 'quantity.auto.tfvars'

Here is an excerpt from quantity.auto.tfvars showing the modules which you can enable/disable.  There are no interdependencies between modules, so you can enable any combination.  The 'Phone Shop' module is currently the only one using APM

```yaml
### Enable / Disable Modules
instances_enabled = true
phone_shop_enabled = true
lambda_sqs_dynamodb_enabled = true
dashboards_enabled = true
detectors_enabled = true
```

### Instances

This module deploys some example EC2 Instances as well as Otel Collectors. Each instance is deployed with a smart_agent to enable Infrastructure Monitoring and is configured to send all metrics via the cluster of Otel Collectors via an AWS LOad Balancer which is also auto deployed.

The following EC2 Instances can be deployed:

..*Collectors
..*HAProxy
..*MySQL
..*Wordpress (just a basic Apache server in reality)

Each Instance has Infrastructure Monitoring 'monitors' configured to match the services running on them.  The configuration for each monitor is deployed into /etc/signalfx/monitors/xxx.yaml, this means the /etc/signalfx/agent.yaml file is the same regardless of role.

The quantity of each Instance deployed is also controlled via quantity.auto.tfvars so you can deploy between 0 & 3 of each type, but you should always deploy at least 1 collector.

```yaml
collector_count = "3" # min 1 : max 3
collector_ids = [
    "Collector1",
    "Collector2",
    "Collector3"
    ]

haproxy_count = "2" # min 0 : max 3
haproxy_ids = [
    "haproxy1",
    "haproxy2",
    "haproxy3"
    ]

mysql_count = "2" # min 0 : max 3
mysql_ids = [
    "mysql1",
    "mysql2",
    "mysql3"
    ]

wordpress_count = "2" # min 0 : max 3
wordpress_ids = [
    "wordpress1",
    "wordpress2",
    "wordpress3"
    ]
```
