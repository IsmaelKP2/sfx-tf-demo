#! /bin/bash
# Version 2.0

ENVIRONMENT=$1
# echo $ENVIRONMENT > /tmp/environment # just for debugging

sed -i -e "s+    #defaultSpanTags:+    defaultSpanTags:+g" /etc/signalfx/agent.yaml
sed -i -e "s+     #environment: \"YOUR_ENVIRONMENT\"+     environment: \"$ENVIRONMENT\"+g" /etc/signalfx/agent.yaml
