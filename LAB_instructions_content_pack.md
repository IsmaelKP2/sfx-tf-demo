Prerequisites:

to perform this lab you need :

1. Terraform installed https://www.terraform.io/
2. AWS credentials (AWS console ?) 
	AWS Account aws_access_key_id 
	aws_secret_access_key
	SSH Key 
3. An observability cloud organisation ID. 
4. Have data ingested in the environmment for this workshop

note: we have deploy the online boutique of the observability workshop on a aws instance available here https://signalfx.github.io/observability-workshop/v3.13/ <br/>


we have connected our AWS instance to the observability suite <br/>

the environnement used for this workshop looks like this 

<img width="1192" alt="Screenshot 2022-01-13 at 16 16 44" src="https://user-images.githubusercontent.com/34278157/149367458-ab52468b-c916-4e82-be53-63e389fde927.png">

Open sfx-tf-demo in your preferred code editor. <br/>

```
cp terraform.tfvars.example terraform.tfvars
```

### Hands on:

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

The Splunk ITSI Module requires various files that cannot be included in this repo and need to be downloaded from https://splunkbase.splunk.com/ 

itsi_license_filename <br />
splunk-app-for-content-packs_140.spl <br />
splunk-it-service-intelligence_493.spl <br />
splunk-synthetic-monitoring-add-on_107.spl" <br />
splunk-infrastructure-monitoring-add-on_121.tgz <br />

(refer to README.md for details of the configuration)

### Download the files via the link provided by the instructor or from downloading the apps from splunkbase.com and install it locally 

place the file 
on MAC in ~/Downloads <br />
on Windows in %USERPROFILE%\Downloads note you also nee to change the terraform.tfvars line 139 to  %USERPROFILE%\Downloads

### Deploy the instance

go into sfx-tf-demo <br />

run <br />

```terraform init```

run 

```terraform plan``` 

```
var.region
  Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )

  Enter a value:
```

enter 1 for the region <br />

At the bottom of your editor you should get the output <br />
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

Note If you get an error review the previous steps. <br />

run

```terraform apply```

```
Do you want to perform these actions? 
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```
Enter yes <br />

Note if you get an error run terraform destroy and restart the installation. <br />

You should get the output below: <br />
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

Login to your newly created splunk instance using: <br />
the address -> Splunk_ITSI_URL <br />
username -> admin <br />
password -> Splunk_ITSI_Password <br />

## 3. Configuration of the Add-on and Content Pack ##

### Set up the Splunk Infrastructure Monitoring Add-on and enable the enable the content pack ###

Configure the Infrastructure Add-on documentation can be found here https://docs.splunk.com/Documentation/SIMAddon/1.2.1/Install/InstallOverview <br />

Configure the Content Pack for Observability documentation can be found here https://docs.splunk.com/Documentation/CPObservability/latest/CP/Install <br />

Note: import as disabled do no use prefix and do not use a backfill to accelerate the deployment process and have a more step by step approach to the install.
also not that the modular inputs are already included in the terraform script to save time on the config <br />

### Import your  entities  ###


Go to Settings -> Searches, Reports, and Alerts 

Select App Splunk Observability Cloud | Owner All

Find the line ITSI Import Objects - Get_OS_Hosts -> (Actions) Edit -> Enable

NOTE those searches are called Cloud Entity Searches 

Open ITSI ->  Infrastructure Overview

###  Enable the ITSI Services from the content packs  ###

Go to Configuration -> Services

Enable the services in the status column  :

1. OS Hosts 
2. Infrastructure Monitoring
3. My Data Center Hosts 
4. Splunk Observability Cloud
5. AWS 
6. AWS EC2 

Go to ITSI Service Analyzers -> Default Service Analyzer (Check your services status)

NOTE: It can take a few minutes for the service to show up in the UI

## 4. Create a custom service 

### Built a KPI search the fast way

Open the EBS Dashboard -> open Total Ops/Reporting Interval -> view signalflow <br />

<img width="1379" alt="Screenshot 2022-01-13 at 16 20 45" src="https://user-images.githubusercontent.com/34278157/149368157-22e4a1ab-d88a-41b5-ae81-97f29b22b40f.png">

You should see the following : <br />
```
A = data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='A')
B = data('VolumeWriteOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').scale(60).sum().publish(label='B')
```
Let's change the signalflow to create a simple query for VolumeReadOps in Splunk Enterprise : <br />

```
data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').publish()
```

In Splunk Enterprise open Search and Reporting : <br />

run the following command: <br />

```
| sim flow query="data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').publish()"
```

if you want to build a chart run <br />

```
| sim flow query="data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').publish()"
| timechart max(_value) span=5m
```

###  Let's create our EBS service <br />

Make sure to go into Splunk IT Service Intelligence.
Configuration -> Service -> Create services -> Create service <br />
Enter Title: EBS volumes <br />
Select Manually add service content <br />

<img width="589" alt="Screenshot 2022-01-14 at 10 16 37" src="https://user-images.githubusercontent.com/34278157/149499220-63ad5524-7328-46f5-becb-c75acb3d62e7.png">

KPI -> new -> Generic KPI <br />
Click Next <br />
Paste the command below in the textbox <br />

```
| sim flow query="data('VolumeReadOps', filter=filter('namespace', 'AWS/EBS') and filter('stat', 'sum'), rollup='rate', extrapolation='zero').publish()"
| rename _value as VolumeReadOps
```
 <br />
	In the treshold field enter VolumeReadOps (you can keep everything default for the rest of the configuration)  <br />
	click next <br />
	click next <br />
	click next <br />
	add threshold manually (if nothing is happening on the Disk it might show close to 0 as a number) <br />
	save on the bottom of the page !!! <br />
	Let's attach our standalone to the AWS service <br />
	go to Service open AWS service <br />
	go to Service Dependencies tab <br />
	Add Dependencies <br />
	Use the filter to select EBS volumes <br />
	Select the service health score  <br />
	go to Service Analyzer -> Default Analyzer <br />
	review what you built <br />

## 5. Working with Entity types

### Enable the Splunk APM Services

Enable APM Service 4 service to enable. <br />

1. Application Duration 
2. Application Error Rate 
3. Application Performance Monitoring 
4. Application Rate (Throughput) 

###  Enable Cloud Entity Search for APM  <br />

Go to Settings -> Searches, Reports, and Alerts  <br />

Select App Splunk Observability Cloud | Owner All  <br />
Find the line ITSI Import Objects - Splunk-APM Application Entity Search -> (Actions) Edit -> Enable  <br />
NOTE those searches are called Cloud Entity Searches  <br />
Open ITSI ->  Infrastructure Overview  <br />
Verify that you have your entities are showing up <br />
Note: there isn't any out of the box Key vital metrics so the visualisation will look like this <br />

<img width="247" alt="Screenshot 2022-01-13 at 15 50 57" src="https://user-images.githubusercontent.com/34278157/149363052-ca443f77-5c01-466f-bb91-53c1b8059799.png"> <br />


###  Add a dashboard Navigation <br />

Configuration -> Entity management -> Entity Types <br />
Find SplunkAPM -> Edit <br />
Open Navigations type <br />
Navigation Name: Traces View <br />
URL : https://app.${sf_realm}.signalfx.com/#/apm/traces<br />
Save navigation !! <br />
Save Entity type <br />
        
In Service Analyzer open a Splunk APM entity and test your new navigation suggestion <br />

<img width="809" alt="Screenshot 2022-01-13 at 15 54 49" src="https://user-images.githubusercontent.com/34278157/149363707-0ccd43b6-e53b-4144-a130-57f92e9bfd37.png">

###  Add Key Vital metrics for Splunk APM. <br />


Configuration -> Entity management -> Entity Types <br />
          Find SplunkAPM -> Edit <br />
          Open Vital Metrics <br />
          Enter a name  <br />
          Add a metric  <br />
	  Enter the search below and click run search <br />

```
| mstats avg(*) span=5m WHERE "index"="sim_metrics" AND sf_streamLabel="thruput_avg_rate" GROUPBY sf_service sf_environment | rename avg(service.request.count) as "val"
```

Entity matching field sf_service  <br />
(note: verify that you are matching entities 10 entities matched in last hour)  <br />
Unit of Display Percent (%)  <br />
Choose a Key Metric Select Application Rate Thruput  <br />
Save Application Rate  <br />
Save Entity Type  <br />

your UI should look like this should look like this <br />

<img width="246" alt="Screenshot 2022-01-13 at 15 50 46" src="https://user-images.githubusercontent.com/34278157/149379166-bcbbe8f1-0190-41e5-ac60-d48808ffa25d.png">


## 6. destroy all of your good work 

```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

Enter yes

