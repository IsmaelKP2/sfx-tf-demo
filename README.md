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

There are generally no interdependencies between modules, so you can deploy almost any combination.

The quantities of each EC2 Instance deployed as part of the 'Instances & Proxied Instances' Modules are also controlled here. You can deploy as many itsi instance as participants 0 & 3 of most types, but you should always deploy at least 1 Collector (Instances Module), which gets deployed behind an AWS ALB, and is used by the Instances to send in their metrics to the Splunk IM Platform.

```yaml
# This file contains all the settings which are unique to each deployment and it
# should NOT be stored in a public source control system as it contains sensitive information
# If values are commented out, you will be prompted for them at run time, this way you 
# can choose to store the information in this file, or enter it at run time.

### Enable / Disable Modules
itsi_o11y_cp_enabled        = false

## ITSI Quantities ##

splunk_itsi_count = "1" # min 0 : max = 1 as only one is required, used as a yes/no parameter
splunk_itsi_ids = [
  "splunk-itsi-001"
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

A new VPC is created and is used. The number of subnets is controlled by the 'subnet_count' parameter, and defaults to 2 which should be sufficient for most test cases.

Two sets of subnets will be created, a Private and a Public Subnet, so by default 4 subnets will be created. Each Subnet will be created using a CIDR allocated from the 'vpc_cidr_block', so by default the 1st subnet will use 172.32.0.0/24, the 2nd subnet will use 172.32.1.0/24 etc.

```yaml
### AWS Variables ###
#region = "<REGION>"

## VPC Settings ##
vpc_cidr_block        = "172.32.0.0/16"
subnet_count          = "2" 

## Auth Settings ##
key_name              = "<NAME>"
private_key_path      = "~/.ssh/id_rsa"
instance_type         = "t2.micro"
aws_access_key_id     = "<ACCCESS_KEY_ID>>"
aws_secret_access_key = "<SECRET_ACCESS_KEY>>"
```

### Splunk IM/APM Variables

Settings used by Splunk IM/APM for authentication, notifications and APM Environment.  An example of an Environment value would be "TF Demo", it's a simple tag used to identify and link the various components within the Splunk APM UI.

Optionally you can specify a version for the smart_agent, but if left blank the latest will be used, which is the recommended option, however as OTEL is replacing the SmartAgent this setting will soon be retired.

The collector_version is currently only used by the Proxied Instances module as it leverages an offline installation method which requires the version number to be specified, all other modules that use OTEL will use the latest by default.

```yaml
### Splunk IM/APM Variables ###
access_token             = "<ACCESS_TOKEN>"
api_url                  = "https://api.<REALM>.signalfx.com"
realm                    = "<REALM>"
environment              = "<ENVIRONMENT>"
notification_email       = "<EMAIL>"
smart_agent_version      = "" # Optional - If left blank, latest will be installed - example value would be "5.7.1-1"
ecs_agent_url            = "https://raw.githubusercontent.com/geoffhigginbottom/sfx-tf-demo/master/modules/aws_ecs/agent_fargate.yaml"
ms_sql_agent_url         = "https://raw.githubusercontent.com/geoffhigginbottom/sfx-tf-demo/Master/modules/instances/config_files/ms_sql_agent_config.yaml"
windows_server_agent_url = "https://raw.githubusercontent.com/geoffhigginbottom/sfx-tf-demo/Master/modules/instances/config_files/windows_server_agent_config.yaml"
collector_version        = "0.40.0"
```

### Splunk ITSI Variables

The Splunk ITSI Module requires various files that cannot be included in this repo and need to be downloaded from https://splunkbase.splunk.com/ then their locations specified in this section

```yaml
### Splunk ITSI Variables ###
splunk_itsi_inst_type                             = "t2.large"
splunk_itsi_version                               = "8.2.3"
splunk_itsi_filename                              = "splunk-8.2.3-cd0848707637-linux-2.6-amd64.deb"
splunk_itsi_files_local_path                      = "~/Downloads" # path where itsi files resides on your local machine 
splunk_itsi_license_filename                      = "Splunk_ITSI_NFR_FY23.lic" # this file should NOT be included in the repo, and shoule be located in the itsi_files_local_path location
splunk_app_for_content_packs_filename             = "splunk-app-for-content-packs_140.spl" # this file should NOT be included in the repo, and shoule be located in the itsi_files_local_path location
splunk_it_service_intelligence_filename           = "splunk-it-service-intelligence_493.spl" # this file should NOT be included in the repo, and shoule be located in the itsi_files_local_path location
splunk_synthetic_monitoring_add_on_filename       = "splunk-synthetic-monitoring-add-on_107.tgz" # this file should NOT be included in the repo, and shoule be located in the itsi_files_local_path location
splunk_infrastructure_monitoring_add_on_filename  = "splunk-infrastructure-monitoring-add-on_121.tgz" # this file should NOT be included in the repo, and shoule be located in the itsi_files_local_path location
```

# Modules

Details about each module can be found below

## Splunk ITSI

This module deploys a Splunk ITSI Instance, and sets up a number of content packs and add-ons, which are all automatically installed and configured.
