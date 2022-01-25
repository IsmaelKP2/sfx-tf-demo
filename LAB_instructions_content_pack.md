### Login to you splunk instance

The instructor should provide you with an ITSI instance

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




