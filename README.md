# Splunk Observability Terraform Demo

# Introduction

This is a collection of Terraform Modules which can be used to deploy a test environment into a new AWS VPC.  The purpose is to enable you to deploy some typical AWS resources, and at the same time, deploy Splunk Infrastructure Monitoring and Splunk Application Performance Monitoring, combining "Infrastructure as Code" with "Monitoring as Code". The aim is to provide fully configured working examples to supplement the official Splunk documentation.

# Requirements

To use this repo, you need an active AWS account. Where possible resources that qualify for the free tier are used by default to enable deployment to AWS trial accounts with minimal costs.

You will also need a Splunk Infrastructure Monitoring Account. Some modules leverage the Splunk APM features so ideally you will also have APM enabled on your Splunk environment.

The "Detectors" Module requires a Splunk On-Call account with an active integration to Splunk IM, enabling end to end testing of both "Monitoring" and "Incident Response".

# Setup

After cloning the repo, you need to generate and configure a terraform.tfvars file that will be unique to you and will not be synced back to the repo (if you are contributing to this repo).

Copy the included terraform.tfvars.example file to terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Update the contents of terraform.tfvars replacing any value contained within <> to suit your environment.  Note some values have been pre-populated with typical values, ensure you review every setting and update as appropriate.

Any value can be removed or commented out with a #, by doing so Terraform will prompt you for the appropriate value at run time.

The following describes each section of terraform.tfvars:

## terraform.tfvars

### Enable / Disable Modules

There are a number of core modules which are always deployed such as VPC and Security Groups, but the modules listed under the 'Enable / Disable Modules' comment can be activated by changing the values from the default of "false" to "true".

You will find more information about each Module at the end of this document.

There are no interdependencies between modules, so you can deploy any combination.  The 'EKS Cluster', 'ECS Cluster' and 'Phone Shop' modules all have APM enabled and are instrumented to emit Traces.

The quantities of each EC2 Instance deployed as part of the 'Instances' Module are also controlled here. You can deploy between 0 & 3 of most types, but you should always deploy at least 1 Collector, which gets deployed behind an AWS ALB, and is used by the Instances to send in their metrics to the Splunk IM Platform.

```yaml
# This file contains all the settings which are unique to each deployment and it
# should NOT be stored in a public source control system as it contains sensitive information
# If values commented out, you will be prompted for them at run time, this way you 
# can choose to store the information in here, or enter it at run time.

### Enable / Disable Modules
eks_cluster_enabled         = false
instances_enabled           = false
phone_shop_enabled          = false
lambda_sqs_dynamodb_enabled = false
dashboards_enabled          = false
detectors_enabled           = false

## Instance Quantities ##
collector_count = "2" # min 1 : max = subnet_count
collector_ids = [
  "Collector1",
  "Collector2",
  "Collector3"
  ]

haproxy_count = "1" # min 0 : max = subnet_count
haproxy_ids = [
  "haproxy1",
  "haproxy2",
  "haproxy3"
  ]

mysql_count = "1" # min 0 : max = subnet_count
mysql_ids = [
  "mysql1",
  "mysql2",
  "mysql3"
  ]

ms_sql_count = "1" # min 0 : max = subnet_count
ms_sql_ids = [
  "ms_sql1",
  "ms_sql2",
  "ms_sql3"
  ]

apache_count = "1" # min 0 : max = subnet_count
apache_ids = [
  "apache1",
  "apache2",
  "apache3"
  ]

splunk_ent_count = "0" # min 0 : max = 1 as only one is required, used as a yes/no parameter
splunk_ent_ids = [
  "splunk_ent1"
  ]
```

### AWS Variables

This section details the parameters required by AWS such as Region (see below for more info on this), VPC settings, SSH Auth Key, and authentication to your AWS account.

#### Region

When you run the deployment terraform will prompt you for a Region, however if you enable the setting here, and populate it with a numerical value representing your preferred AWS Region, it will save you having to enter a value on each run. The settings for this are controlled via variables.tf, but the valid options are:

- 1: eu-west-1
- 2: eu-west-3
- 3: eu-central-1
- 4: us-east-1
- 5: us-east-2
- 6: us-west-1
- 7: us-west-2
- 8: ap-southeast-1
- 9: ap-southeast-2
- 10: sa-east-1

#### VPC Settings

A new VPC is created and is used by the EKS Cluster, Instances, Phone Shop & Lambda SQS Dynamo DB modules (the ECS Cluster Module creates its own VPC).  The number of subnets is controlled by the 'subnet_count' parameter, and defaults to 2 which should be sufficient for most test cases.

Two sets of subnets will be created, a Private and a Public Subnet, so by default 4 subnets will be created. Each Subnet will be created using a CIDR allocated from the 'vpc_cidr_block', so by default the 1st subnet will use 172.32.0.0/24, the 2nd subnet will use 172.32.1.0/24 etc.

Note: The ECS Cluster Module will create its own unique VPC and Subnets and creates a Fargate deployment.  At present all the variables controlling this are contained within the ECS Cluster modules variables.tf file (modules/aws_ecs/variables.tf).

```yaml
### AWS Variables ###
#region = "<REGION>"

## VPC Settings ##
vpc_cidr_block = "172.32.0.0/16"
subnet_count   = "2" 

## Auth Settings ##
key_name = "<NAME>"
private_key_path = "~/.ssh/id_rsa"
instance_type = "t2.micro"
aws_access_key_id = "<ACCCESS_KEY_ID>>"
aws_secret_access_key = "<SECRET_ACCESS_KEY>>"
```

### SOC Variables

Settings used by the Splunk On-Call Integration within Splunk IM/APM to create Incidents from the Alerts generated by Splunk IM/APM.

```yaml
### SOC Variables ###
soc_integration_id = "<ID>"
soc_routing_key = "<ROUTING_KEY>"
```

### Splunk IM/APM Variables

Settings used by Splunk IM/APM for authentication, notifications and APM Environment.  An example of an Environment value would be "TF Demo", it's a simple tag used to identify and link the various components within the Splunk APM UI.

Optionally you can specify a version for the smart_agent, but if left blank the latest will be used, which is the recommended option.

```yaml
### SignalFX Variables ###
access_token = "<ACCESS_TOKEN>"
api_url = "https://api.<REALM>.signalfx.com"
realm = "<REALM>"
environment = "<ENVIRONMENT>"
notification_email = "<EMAIL>"

smart_agent_version = "" # Optional - If left blank, latest will be installed - example value would be "5.7.1-1"
```

### Collector Variables

One or more OpenTelemetry Collectors are deployed as part of the Instances Module, behind an ELB, and are configured for both IM and APM.

```yaml
### Collector Variables ###
### https://quay.io/repository/signalfx/splunk-otel-collector?tab=tags
otelcol_version = "0.21.1"
ballast = "683"
collector_instance_type = "t2.small"
```

## Instances

This module deploys some example EC2 Instances, with Splunk IM Monitors matching their role, as well as Otel Collectors. Each instance is deployed with a smart_agent to enable Infrastructure Monitoring and is configured to send all metrics via the cluster of Otel Collectors, fronted by an AWS Load Balancer.

The following EC2 Instances can be deployed:

- Collectors
- HAProxy
- MySQL
- MS SQL
- Apache (just a basic Apache server in reality)
- Splunk Enterprise

Each Instance has Infrastructure Monitoring 'monitors' configured to match the services running on them.  The configuration for each monitor is deployed into /etc/signalfx/monitors/xxx.yaml, this means the /etc/signalfx/agent.yaml file is the same regardless of role.

## Phone Shop

This is based on the Lambda components of the [Splunk Observability Workshop](https://signalfx.github.io/observability-workshop/latest/), but unlike the workshop version, is fully configured for APM.  As well as deploying the Lambda Functions fully instrumented, and their required API Gateways, the EC2 Instance 'vm_phone_shop' is configured to automatically generate random load to ensure APM Traces are generated within a couple of minutes of deployment.

## Lambda SQS DynamoDB

This module deploys a Lambda function which is triggered by an SQS queue, storing the messages from the queue into a DynamoDB table.  An EC2 Instance 'vm_sqs_test_server' is deployed and this instance contains a helper script called 'generate_send_messages' which is deployed into the ubuntu users home folder.  When run, this script places random messages into SQS, triggering the Lambda function which then removes the messages placing them into the DynamoDB table.  This enables testing of SQS triggered Lambda functions when using APM.

## Dashboards

This module creates a new Dashboard Group with an example Dashboard generated by Terraform.  The aim of this module is to simply demonstrate the methods for creating new Dashboard Groups, Charts and Dashboards, using "Monitoring as Code", in parallel with your "Infrastructure as Code" via Terraform.

## Detectors

This module creates a couple of new Detectors as basic examples of creating detectors and leveraging the integration with Splunk On-Call.  A more comprehensive list of example detectors which can be deployed using Terraform can be found [here](https://github.com/signalfx/signalfx-jumpstart).