Terraform deployment + script
	cp terraform.tfvars.example terraform.tfvars
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

## 2 o2##


Install and configure the Splunk Infrastructure Monitoring and Splunk Synthetic Monitoring Add-ons. 
Install the ITSI content pack.
Import your entities.




