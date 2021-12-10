#! /bin/bash
# Version 2.0

PASSWORD=$1
VERSION=$2
FILENAME=$3

# wget -O /tmp/$FILENAME "https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=$VERSION&product=splunk&filename=$FILENAME&wget=true"
wget -O /tmp/$FILENAME "https://download.splunk.com/products/splunk/releases/$VERSION/linux/$FILENAME"
dpkg -i /tmp/$FILENAME
/opt/splunk/bin/splunk cmd splunkd rest --noauth POST /services/authentication/users "name=admin&password=$PASSWORD&roles=admin"
/opt/splunk/bin/splunk start --accept-license --answer-yes --no-prompt --seed-passwd $PASSWORD
/opt/splunk/bin/splunk enable boot-start