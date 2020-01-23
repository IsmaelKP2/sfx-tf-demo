#! /bin/bash
# Version 2.0
TOKEN=$1
REALM=$2
CLUSTERNAME=$3
VERSION=$4

if [ -z "$1" ] ; then
  printf "Token not set, exiting ...\n"
  exit 1
else
  printf "Installing SmartAgent ...\n"
fi

curl -sSL https://dl.signalfx.com/signalfx-agent.sh > /tmp/signalfx-agent.sh
sudo sh /tmp/signalfx-agent.sh --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --cluster $CLUSTERNAME $TOKEN --package-version $VERSION
