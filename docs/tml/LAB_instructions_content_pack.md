<!---
template for local testing:
<img src="http://localhost:8000/sfx-tf-demo/images/im_configure/account.png" alt="Connect Account" style="width: 75%;"/>
<img src="https://ismaelkp2.github.io/sfx-tf-demo/sfx-tf-demo/images/im_configure/account.png" alt="Connect Account" style="width: 75%;"/>
-->


## Task 1: Login to your Splunk Instance

We deeply believe that the best way for you to familiarize yourself with the Splunk IT Service Intelligence (ITSI) Add-On is to get your hands dirty. Therefore, we provided individual sandbox environments in the form of Splunk instances for you. The first task of this workshop for you is to connect to those instances.

**A successful connection to your instance can be established via executing the following steps:**

<span style="color:#FF5733">// Caution: Screenshot and actual Google spreadsheet are just placeholders for now (this webpage is under construction), and don't do anything!</span><br>
1. Access the Instance List by clicking [**HERE**](https://docs.google.com/spreadsheets/d/1hc8tPm1xNGq_KkoPlV6BTmJbG0DJQWto_Jb1jAoKuOI/edit?usp=sharing). 
You should be able to see a Google spreadsheet that looks similar to the screenshotted example below: 
<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/access_aws_instance/access_sheet.png" alt="Spreadsheet" style="width: 50%;"/> <br>
2. In the first column with the title *Name of Attendee* locate your name. **Find your personal access link to the instance on the right of your name** and use it to reach the login page of Splunk Enterprise. It looks like this: <br> 
<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/access_aws_instance/login.png" alt="Login" style="width: 70%;"/> <br>
3. To log in, use the username **admin**. Use the password is provided for you in the [Instance List](https://docs.google.com/spreadsheets/d/1hc8tPm1xNGq_KkoPlV6BTmJbG0DJQWto_Jb1jAoKuOI/edit?usp=sharing). Click the *Sign In*-Button. <br>
4. On a successful login, you might get greeted by pop-up windows showing tips, tutorials, and/or recommendations. These are not important for us right now. Feel free to ignore them by clicking the *Got it!*-Button, or respectively, the *Don't show me this again*-Button. Other than that, you should be able now to see Splunk Enterprise Home view, which initially looks like this: <br> 
<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/access_aws_instance/home_view.png" alt="Homeview" style="width: 70%;"/> <br>
If you fail to see this home view, most likely something went wrong. Please do not hesitate to raise your hand in Zoom, or shoot us a short message in the Zoom channel. An assistent will be with you shortly. 

If that is not the case, we want to congratulate you! You successfully connected to your instance, and thus completed the first task!

<br>

## Task 2: Configure the Infrastructure Add-on and the Observability Content Pack

Now that we have access to our instances, which bear the pre-installed Infrastructure Monitoring Add-On and the Observability Content Pack, we need to configure those two by follwoing the steps below.

### Task 2.1: Configuration of the Infrastructure Monitoring Add-on

1. After you accessed your instance, navigate to the **Splunk Infrastructure Monitoring Add-On** listed on the left under **Apps**. We want to set up an account, and we can do so by navigating to the **Configuration Tab** and clicking on the '**Connect an Account**'-Button. 
<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/account.png" alt="Connect Account" style="width: 75%;"/> <br>
Once you clicked the 'Connect an Account'-Button, a dialogue appears, prompting you for the user credentials of your Observability Cloud account. These are the **Access Token** and the **Realm**, with which the Add-On can access the Oberservability Cloud. In the next steps, we are going to locate our Realm inside our individual Observability Cloud account and create a new Access Token. 

2. Locate your **Realm**: Log in to your Splunk Observability account. In the menu on the left on the bottom click on the little <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/gear.png" alt="Gear Icon" style="width: 3%; vertical-align:middle;"/> icon (<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/settings.png" alt="Settings Icon" style="width: 15%; vertical-align:middle;"/> respectively if the menu is expanded). On the very top of this menu, you should see your **username** right next to a profile picture. Click on it. You are now in the Account Settings, where you can find the Realm *(see screenshot below)*. <br>
<img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/account_settings.png" alt="Account Settings" style="width: 70%;"/> <br>
Copy and paste the Realm into the input field of of the dialogue in the IM Add-On.

3. Locate your **Access Token**: Being still in your Account Settings, click on <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/generate_token.png" alt="Generate Token" style="width: 15%; vertical-align:middle;"/> to generate an access token, and subsequently on <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/show_token.png" alt="Show Token" style="width: 13.5%; vertical-align:middle;"/> to show the associated string. Copy and paste that string into the input field of of the dialogue in the IM Add-On. 

4. Once the Realm and Access Token have been inserted into the input dialogue, make sure to verify whether or not a connection to the Observability Cloud could be established by clicking on the **Check Connection**-button. If so, click submit. You can enable data collection for the account by selecting the *Data Collection* toggle.

*For additional information on this topic, see [Configure the Splunk Infrastructure Monitoring Add-on](https://docs.splunk.com/Documentation/SIMAddon/1.2.1/Install/Configure).*

*Watch this video introducing the content pack concepts.

<iframe class="vidyard_iframe" src="//play.vidyard.com/cB6Wq1dEy7hZGm7CjdSZm6.html?" width="640" height="360" scrolling="no" frameborder="0" allowtransparency="true" allowfullscreen></iframe>


### Task 2.2: Configure the Content Pack for Observability

1. As soon as we have successfully configured the Infrastructure Monitoring Add-On, we will continue by installing and configuring the Content Pack for Observability. The first step to accomplish that is to select the **IT Service Intelligence** app. Inside the app, click on the **Configuration** tab and select **Data Integrations** from the dopdown menu. <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/im_configure/data_integrations.png" alt="Data Ingestions" style="width: 90%;"/>

2. On the next screen, select *Add content packs* and choose *Splunk Observability Cloud*. <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/cp_configure/add.png" alt="Add Content Pack" style="width: 90%;"/>

3. Upon clicking on the *Splunk Observability Cloud*-tile, you are presented with an overview of what is included in the Content Pack. Review it, and finally click on <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/cp_configure/proceed_button.png" alt="Proceed Button" style="width: 7.5%; vertical-align:middle;"/>.

4. Next, you are presented with a settings menu to configure the content pack. <span style="color:#FF5733">The following is important:</span><br> Please disable the *Import as enable*-option, leave the *Enter a prefix* input field blank, and disable the *Backfill service KPIs* option. <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/cp_configure/settings.png" alt="Settings" style="width: 70%;"/> <br>
Finally, click on the [Install selected] button. 

5. The *Splunk Observability Cloud* tile on the *Data Integrations* page should now have a little green checkmark on the upper right corner. This means that we are all set. Perfect! <img src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/cp_configure/checkmark.png" alt="Checkmark" style="width: 15%;"/>


*For additional information on this topic, see [Install the Content Pack for Splunk Observability Cloud](https://docs.splunk.com/Documentation/CPObservability/1.0.0/CP/Install#Install_the_Content_Pack_for_Splunk_Observability_Cloud).*

## Task 3: Create a custom service

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


### Task 3.1: Let's create our EBS service <br />

Make sure to go into Splunk IT Service Intelligence. <br />
Configuration -> Service -> Create services -> Create service <br />
Enter Title: EBS volumes <br />
Select Manually add service content <br />

(screenshot to be added)

KPI -> new -> Generic KPI <br />
Click Next <br />
Paste the command we just created in the textbox <br />

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


## Task 4: Get to know Entity types

### Task 4.1: Splunk APM Entity type
tbc
### Task 4.2: Enable Modular Input for APM error rate and APM thruput

### Task 4.3: Enable the Splunk APM Services

Enable APM Service (4 service to enable) <br />

1. Application Duration 
2. Application Error Rate 
3. Application Performance Monitoring 
4. Application Rate (Throughput) 

### Task 4.4: Enable Cloud Entity Search for APM  <br />

Go to Settings -> Searches, Reports, and Alerts  <br />

Select App Splunk Observability Cloud | Owner All  <br />
Find the line ITSI Import Objects - Splunk-APM Application Entity Search -> (Actions) Edit -> Enable  <br />
NOTE those searches are called Cloud Entity Searches  <br />
Open ITSI ->  Infrastructure Overview  <br />
Verify that you have your entities are showing up <br />
Note: there isn't any out of the box Key vital metrics so the visualisation will look like this <br />

<img width="247" alt="Screenshot 2022-01-13 at 15 50 57" src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/custom_service/SplunkAPM.png"> <br />


###  Task 4.5: Add a dashboard Navigation <br />

Configuration -> Entity management -> Entity Types <br />
Find SplunkAPM -> Edit <br />
Open Navigations type <br />
Navigation Name: Traces View <br />
URL : https://app.${sf_realm}.signalfx.com/#/apm/traces<br />
Save navigation !! <br />
Save Entity type <br />
        
In Service Analyzer open a Splunk APM entity and test your new navigation suggestion <br />

<img width="809" alt="Screenshot 2022-01-13 at 15 54 49" src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/custom_service/navigation_suggestion.png"">

###  Task 4.6: Add Key Vital metrics for Splunk APM. <br />

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

<img width="246" alt="Screenshot 2022-01-13 at 15 50 46" src="https://raw.githubusercontent.com/IsmaelKP2/sfx-tf-demo/standalone/docs/images/custom_service/vital_metric.png">
