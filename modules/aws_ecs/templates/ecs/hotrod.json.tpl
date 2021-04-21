    [
        {
            "name": "signalfx-agent",
            "image": "quay.io/signalfx/signalfx-agent:5.9.2",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-group": "${environment}/ecs",
                  "awslogs-region": "${region}",
                  "awslogs-stream-prefix": "signalfx-agent"
                }
            },
            "entryPoint": [
                "bash",
                "-c"
            ],
            "command": [
                "curl --fail $CONFIG_URL > /etc/signalfx/agent.yaml && exec /bin/signalfx-agent"
            ],
            "environment": [
                {
                    "name": "ACCESS_TOKEN",
                    "value": "${access_token}"
                },
                {
                    "name": "INGEST_URL",
                    "value": "https://ingest.${realm}.signalfx.com"
                },
                {
                    "name": "API_URL",
                    "value": "https://api.${realm}.signalfx.com"
                },
                {
                    "name": "CONFIG_URL",
                    "value": "${agent_url}"
                },
                {
                    "name": "TRACE_ENDPOINT_URL",
                    "value": "https://ingest.${realm}.signalfx.com/v2/trace"
                },
                {
                    "name": "SPAN_TAGS",
                    "value": "${environment}-ecs-hotrod"
                }
            ],
            "dockerLabels": {
                "app": "signalfx-agent"
            }
        },
        {
            "name": "hotrod",
            "image": "${app_image}",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-group": "${environment}/ecs",
                  "awslogs-region": "${region}",
                  "awslogs-stream-prefix": "hotrod"
                }
            },
            "portMappings": [
                {
                  "containerPort": ${app_port},
                  "hostPort": ${app_port}
                }
            ],
            "environment": [
                {
                    "name": "JAEGER_ENDPOINT",
                    "value": "http://localhost:9080/v1/trace"
                }
            ]
        }
    ]