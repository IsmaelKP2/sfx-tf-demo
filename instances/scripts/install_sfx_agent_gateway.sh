#! /bin/bash
# Version 2.0
TOKEN=$1
REALM=$2
CLUSTERNAME=$3
HOSTNAME=$4
VERSION=$5

if [ -z "$1" ] ; then
  printf "Token not set, exiting ...\n"
  exit 1
else
  printf "Token Vriable Detected ...\n"
fi

if [ -z "$2" ] ; then
  printf "Realm not set, exiting ...\n"
  exit 1
else
  printf "Realm Variable Detected ...\n"
fi

if [ -z "$3" ] ; then
  printf "Clustername not set, exiting ...\n"
  exit 1
else
  printf "Clustername Variable Detected...\n"
fi

if [ -z "$4" ] ; then
  printf "Hostname not set, exiting ...\n"
  exit 1
else
  printf "Hostname Variable Detected...\n"
fi

curl -sSL https://dl.signalfx.com/signalfx-agent.sh > /tmp/signalfx-agent.sh

if [ -z "$5" ] ; then
  printf "Version not specified, installing Latest version ...\n"
  sudo sh /tmp/signalfx-agent.sh --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --cluster $CLUSTERNAME $TOKEN
  exit 1
else
  printf "Version Variable Detected - Installing SignalFX Version $VERSION ..\n"
  sudo sh /tmp/signalfx-agent.sh --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --cluster $CLUSTERNAME $TOKEN --package-version $VERSION
fi

sudo mv /etc/signalfx/agent.yaml /etc/signalfx/agent.yaml.bak

cat << EOF > /etc/signalfx/agent.yaml
---
hostname: $HOSTNAME
signalFxAccessToken: {"#from": "/etc/signalfx/token"}
ingestUrl: {"#from": "/etc/signalfx/ingest_url", default: "https://ingest.signalfx.com"}
apiUrl: {"#from": "/etc/signalfx/api_url", default: "https://api.signalfx.com"}
cluster: {"#from": "/etc/signalfx/cluster", optional: true}

intervalSeconds: 1

logging:
  # Valid values are 'debug', 'info', 'warning', and 'error'
  level: info

# observers are what discover running services in the environment
observers:
  - type: host

monitors:
  - {"#from": "/etc/signalfx/monitors/*.yaml", flatten: true, optional: true}
  - type: host-metadata
  - type: collectd/cpu
  - type: collectd/cpufreq
  - type: collectd/df
    reportByDevice: yes
  - type: collectd/disk
  - type: collectd/interface
  - type: collectd/load
  - type: collectd/memory
  - type: collectd/signalfx-metadata
    extraDimensions:
      source: gateway
      cluster: {"#from": "/etc/signalfx/cluster", optional: true}
  - type: collectd/vmem

metricsToExclude:
  - {"#from": "/usr/lib/signalfx-agent/lib/whitelist.json", flatten: true}

enableBuiltInFiltering: true
EOF

sudo service signalfx-agent restart