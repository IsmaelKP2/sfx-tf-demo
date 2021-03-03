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

curl -sSL https://dl.signalfx.com/signalfx-agent.sh > /tmp/signalfx-agent.sh

if [ -z "$4" ] ; then
  printf "Version not specified, installing Latest version ...\n"
  sudo sh /tmp/signalfx-agent.sh --trace-url https://ingest.$REALM.signalfx.com/v2/trace --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --cluster $CLUSTERNAME $TOKEN
  exit 1
else
  printf "Version Variable Detected - Installing SignalFX Version $VERSION ..\n"
  sudo sh /tmp/signalfx-agent.sh --trace-url https://ingest.$REALM.signalfx.com/v2/trace --ingest-url https://ingest.$REALM.signalfx.com --api-url https://api.$REALM.signalfx.com --cluster $CLUSTERNAME $TOKEN --package-version $VERSION
fi