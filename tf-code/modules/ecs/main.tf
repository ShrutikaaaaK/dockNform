resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = var.log_retention_days
}

# Task definition (Fargate)
resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-td"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = var.container_name,
      image     = "${var.ecr_repository_url}:latest",
      essential = true,
      portMappings = [{
        containerPort = var.container_port,
        hostPort      = var.container_port,
        protocol      = "tcp"
      }],
      linuxParameters = { initProcessEnabled = false },
      environment = [
        { name = "PORT", value = tostring(var.container_port) }
      ],
      secrets = [
        { name = "DEMO_SECRET", valueFrom = var.ssm_secret_name }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "ecs"
        }
      },
      privileged             = false,
      readonlyRootFilesystem = true
    }
  ])
}

data "aws_region" "current" {}

resource "aws_ecs_service" "this" {
  name                    = "${var.name_prefix}-svc"
  cluster                 = aws_ecs_cluster.this.id
  task_definition         = aws_ecs_task_definition.this.arn
  desired_count           = var.desired_count
  launch_type             = "FARGATE"
  enable_execute_command  = true

  network_configuration {
    subnets         = var.subnet_ids
    security_groups = [var.service_sg_id]
    assign_public_ip = var.assign_public_ip
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition] # zero-downtime TD updates
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

output "cluster_name" { value = aws_ecs_cluster.this.name }
