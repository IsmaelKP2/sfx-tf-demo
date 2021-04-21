variable "region" {
  default = {}
}

variable "environment" {
  default = {}
}

variable "access_token" {
  default = []
}

variable "realm" {
  default = []
}

variable "ecs_vpc_name" {
  default = "ecs_vpc"
}

variable "ecs_agent_url" {
  description = "Path to the agent file to be used for ecs"
  default     = {}  
}

variable "ecs_app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = {}
}

variable "ecs_az_count" {
  description = "Number of AZs to cover in a given region"
  default     = {}
}

variable "ecs_health_check_path" {
  description = "Path used by ALB for Health Checks"
  default = {}
}

variable "ecs_app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = {}
}

variable "ecs_container_name" {
  description = "Name of the coantiner deployed in ECS"
  default     = {}
}

variable "ecs_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = {}
}

variable "ecs_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = {}
}

variable "ecs_app_count" {
  description = "Number of docker containers to run"
  default     = {}
}

# variable "ecs_task_execution_role_name" {
#   description = "ECS task execution role name"
#   default = "ECS_TaskExecutionRole"
# }