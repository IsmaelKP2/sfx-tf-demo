    [
        {
            "name": "signalfx-agent",
            "image": "quay.io/signalfx/signalfx-agent:5.9.2",
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                  "awslogs-group": "/ecs/tfdemo",
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
                    "value": "dAb_HPT5SSP243Af4lYikg"
                },
                {
                    "name": "INGEST_URL",
                    "value": "https://ingest.eu0.signalfx.com"
                },
                {
                    "name": "API_URL",
                    "value": "https://api.eu0.signalfx.com"
                },
                {
                    "name": "CONFIG_URL",
                    "value": "https://raw.githubusercontent.com/geoffhigginbottom/sfx-tf-demo/master/modules/aws_ecs/agent_fargate.yaml"
                },
                {
                    "name": "TRACE_ENDPOINT_URL",
                    "value": "https://ingest.eu0.signalfx.com/v2/trace"
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
                  "awslogs-group": "/ecs/tfdemo",
                  "awslogs-region": "${region}",
                  "awslogs-stream-prefix": "ecs"
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