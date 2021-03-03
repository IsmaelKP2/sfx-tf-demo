#! /bin/bash
# Version 2.0

TOKEN=$1
BALLAST=$2
REALM=$3
OTELCOL_VERSION=$4
ENVIRONMENT=$5

cat << EOF > /home/ubuntu/otc_startup.sh
#! /bin/bash
# Version 2.0

TOKEN=$TOKEN
BALLAST=$BALLAST
REALM=$REALM
OTELCOL_VERSION=$OTELCOL_VERSION
ENVIRONMENT=$ENVIRONMENT

sudo docker stop otelcol

sudo docker run -d --rm \\
        -e SPLUNK_ACCESS_TOKEN=\$TOKEN \\
        -e SPLUNK_BALLAST_SIZE_MIB=\$BALLAST \\
        -e SPLUNK_REALM=\$REALM \\
        -e SPLUNK_CONFIG=/etc/collector.yaml \\
        -e SPLUNK_MEMORY_LIMIT_PERCENTAGE=50 \\
        -e SPLUNK_MEMORY_SPIKE_PERCENTAGE=5 \\
        -e SPLUNK_ENVIRONMENT=\$ENVIRONMENT \\
        -p 13133:13133 \\
        -p 14250:14250 \\
        -p 14268:14268 \\
        -p 55678-55680:55678-55680 \\
        -p 6060:6060 \\
        -p 7276:7276 \\
        -p 8888:8888 \\
        -p 9411:9411 \\
        -p 9943:9943 \\
        -v /home/ubuntu/collector.yaml:/etc/collector.yaml:ro \\
        --name otelcol quay.io/signalfx/splunk-otel-collector:\$OTELCOL_VERSION \\
        --log-level=DEBUG

EOF