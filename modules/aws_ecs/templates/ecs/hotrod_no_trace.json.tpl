[
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
    ]
  }
]
