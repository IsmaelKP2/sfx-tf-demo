#! /bin/bash
# Version 2.0
ENDPOINT=$1
HOSTNAME=$2

mv /etc/signalfx/agent.yaml /etc/signalfx/agent-$(date +"%Y%m%d%H%M").bak

cat << EOF > /etc/signalfx/agent.yaml
---
hostname: $HOSTNAME
signalFxAccessToken: {"#from": "/etc/signalfx/token"}
ingestUrl: {"#from": "/etc/signalfx/ingest_url", default: "https://ingest.signalfx.com"}
apiUrl: {"#from": "/etc/signalfx/api_url", default: "https://api.signalfx.com"}
cluster: {"#from": "/etc/signalfx/cluster", optional: true}

traceEndpointUrl: $ENDPOINT

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
  - type: collectd/vmem
  - type: collectd/signalfx-metadata
  - type: signalfx-forwarder
    listenAddress: 127.0.0.1:9080

enableBuiltInFiltering: true
EOF