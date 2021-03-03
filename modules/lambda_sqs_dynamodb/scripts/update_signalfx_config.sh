#! /bin/bash
# Version 2.0
## It's not possible to deploy signalfx with the api and 
## ingest_url pointing at the Collector LB as install fails
## so we update them after the initial installation

LBURL=$1

if [ -z "$1" ] ; then
  printf "LB URL not set, exiting ...\n"
  exit 1
else
  printf "LB URL Variable Detected...\n"
fi

sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml

mv /etc/signalfx/ingest_url /etc/signalfx/ingest_url_old
mv /etc/signalfx/api_url /etc/signalfx/api_url_old
mv /etc/signalfx/trace_endpoint_url /etc/signalfx/trace_endpoint_url_old

echo http://$LBURL:9943 > /etc/signalfx/ingest_url
echo http://$LBURL:6060 > /etc/signalfx/api_url
echo http://$LBURL:7276/v2/trace > /etc/signalfx/trace_endpoint_url
