Prerequisites:

to perform this lab you need :

Terraform installed 

AWS credentials (AWS console ?) AWS Account aws_access_key_id | aws_secret_access_key
SSH Key 

An observability cloud organisation ID. 

Have data ingested in the environmment for this workshop:
we have deploy the online boutique of the observability workshop on a aws instance available here https://signalfx.github.io/observability-workshop/v3.13/
we have connected our AWS instance to the observability suite

Open sfx-tf-demo in your preferred code editor.

```
cp terraform.tfvars.example terraform.tfvars
```

Lab 
## 1 Modify terraform.tfvars file ##
In section Enable / Disable Modules
```
## Enable / Disable Modules ##
itsi_o11y_cp_enabled        = true
```
In section Auth Settings
```
## Auth Settings ##
key_name                = "<NAME>"
private_key_path        = "~/.ssh/id_rsa"
instance_type           = "t2.micro"
aws_access_key_id       = "<ACCCESS_KEY_ID>>"
aws_secret_access_key   = "<SECRET_ACCESS_KEY>>"
```
In section Splunk IM/APM Variables
```
### Splunk IM/APM Variables ###
access_token             = "<ACCESS_TOKEN>"
api_url                  = "https://api.<REALM>.signalfx.com"
realm                    = "<REALM>"
environment              = "<ENVIRONMENT>"
```

## 2 review the variable for ITSI ##


### Splunk ITSI Variables

The Splunk ITSI Module requires various files that cannot be included in this repo and need to be downloaded from https://splunkbase.splunk.com/ then their locations specified in this section


### Download the files via the link provided by the instructor and install it locally 

on MAC in ~Downloads 
on Windows in ...

### Deploy the instance

go into sfx-tf-demo

run

```terraform init```

run

```terraform plan``` 

```
var.region
  Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )

  Enter a value:
```

enter 1 for the region

At the bottom of your editor you should get the output
```
Plan: 10 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + Splunk_ITSI_Password = [
      + (known after apply),
    ]
  + Splunk_ITSI_Server   = [
      + [
          + (known after apply),
        ],
    ]
  + Splunk_ITSI_URL      = [
      + [
          + (known after apply),
        ],
    ]
```

Note If you get an error review the previous steps.

run

```terraform apply```

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```
Enter yes

Note if you get an error run terraform destroy and restart the installation.

You should get the output below:
```
Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

Outputs:

Splunk_ITSI_Password = [
  "xxx.xxx.xxx.xxx",
]
Splunk_ITSI_Server = [
  tolist([
    "ipapa_splunk-itsi, xxx.xxx.xxx.xxx",
  ]),
]
Splunk_ITSI_URL = [
  tolist([
    "http://xxx.xxx.xxx.xxx:8000",
  ]),
]
```

Login to your newly created splunk instance using:
the address -> Splunk_ITSI_URL 
username -> admin
password -> Splunk_ITSI_Password

### Configuration of the Add-on and Content Pack

Configure the Infrastructure Add-on documentation can be found here 

Configure the Content Pack for Observability documentation can be found here 

Note: import as disabled do no use prefix and do not use a backfill to accelerate the deployment process. 

### Hands-on create a custom service 

Open the EBS Dashboard -> open Total Ops/Reporting Interval -> view signalflow

You hould see the following :
```
A = data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='A')
B = data('VolumeWriteOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='B')
```
Let's change the signalflow to create our query in Splunk Enterprise :

```
data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='A');
data('VolumeWriteOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='B')
```
In Splunk Enterprise open Search and Reporting :

run the following command:

```
| sim flow query=data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='A');
data('VolumeWriteOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='B')
```
if you want to build a chart 

```
| sim flow query=data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='A');
data('VolumeWriteOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='B')
| timechart max(VolumeReadOps) max(VolumeWriteOps)
```

Let's create our EBS service 

Service -> new service EBS volumes

KPI new generic KPI 

past the SIM command we just created

click next 

add threshold manually

save on the bottom of the page

Let's attach our standalone to the AWS service

go to Service open AWS service

go to dependencies 

add EBS volumes

go to Service Analyzer -> Default Analyzer 

review what you built


### Working with Entity types

Splunk APM Entity type

Enable Modular Input for APM error rate and APM thruput

Enable APM Service 4 service to enable.

Enable Cloud Entity Search for APM 

Add a Dashboards Navigation

Add Key Vital metrics for Splunk APM.


### destroy all of your good work 

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

Enter yes


Configure the Splunk Infrastructure Monitoring and Splunk Synthetic Monitoring Add-ons. 
Configure the ITSI content pack.
Import your entities.




