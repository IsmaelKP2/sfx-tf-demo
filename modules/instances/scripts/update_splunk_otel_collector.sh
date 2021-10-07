#! /bin/bash
# Version 2.0
## Configure the otel agent to use the Collector via the internal address of the LB

LBURL=$1

if [ -z "$1" ] ; then
  printf "LB URL not set, exiting ...\n"
  exit 1
else
  printf "LB URL Variable Detected...\n"
fi

#sed -i -e 's+intervalSeconds.*+intervalSeconds: 1+g' /etc/signalfx/agent.yaml

cp /etc/otel/collector/splunk-otel-collector.conf /etc/otel/collector/splunk-otel-collector.bak

# sed -i -e s+SPLUNK_API_URL.*+SPLUNK_API_URL=http://$LBURL:6060+g /etc/otel/collector/splunk-otel-collector.conf
# sed -i -e s+SPLUNK_INGEST_URL.*+SPLUNK_INGEST_URL=http://$LBURL:9943+g /etc/otel/collector/splunk-otel-collector.conf
# sed -i -e s+SPLUNK_TRACE_URL.*+SPLUNK_TRACE_URL=http://$LBURL:7276/v2/trace+g /etc/otel/collector/splunk-otel-collector.conf
# sed -i -e s+SPLUNK_HEC_URL.*+SPLUNK_HEC_URL=http://$LBURL:9943/v1/log+g /etc/otel/collector/splunk-otel-collector.conf

echo SPLUNK_GATEWAY_URL=$LBURL >> /etc/otel/collector/splunk-otel-collector.conf

systemctl restart splunk-otel-collector