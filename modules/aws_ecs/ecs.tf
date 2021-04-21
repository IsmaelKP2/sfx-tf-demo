resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.environment}_ecs_cluster"
}

data "template_file" "hotrod" {
  template = file("${path.module}/templates/ecs/hotrod.json.tpl")

  vars = {
    app_image      = var.ecs_app_image
    app_port       = var.ecs_app_port
    fargate_cpu    = var.ecs_fargate_cpu
    fargate_memory = var.ecs_fargate_memory
    region         = var.region
    access_token   = var.access_token
    realm          = var.realm
    agent_url      = var.ecs_agent_url
    environment    = var.environment
  }
}

resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = "ecs_task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.ecs_fargate_cpu
  memory                   = var.ecs_fargate_memory
  container_definitions    = data.template_file.hotrod.rendered
}

resource "aws_ecs_service" "ecs_service" {
  name            = "${var.environment}_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = var.ecs_app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_app_tg.id
    container_name   = var.ecs_container_name
    container_port   = var.ecs_app_port
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

