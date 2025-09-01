# 1) Networking
module "network" {
  source                 = "./modules/network"
  name_prefix            = "${var.app_name}-${var.environment}"
  vpc_cidr               = var.vpc_cidr
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  enable_nat             = var.enable_nat
}

# 2) Security Groups
module "security" {
  source                 = "./modules/security"
  name_prefix            = "${var.app_name}-${var.environment}"
  vpc_id                 = module.network.vpc_id
  alb_ingress_cidrs      = var.alb_ingress_cidrs
  container_port         = var.container_port
}

# 3) ECR (scan on push + lifecycle to save cost)
module "ecr" {
  source          = "./modules/ecr"
  repo_name       = var.ecr_repo_name
  scan_on_push    = true
  expire_untagged_after_days = 7
}

# 4) IAM roles for ECS task & execution
module "iam" {
  source                  = "./modules/iam"
  name_prefix             = "${var.app_name}-${var.environment}"
  ssm_parameter_arn       = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter${var.ssm_secret_name}"
}

data "aws_caller_identity" "current" {}

# 5) ALB
module "alb" {
  source                 = "./modules/alb"
  name_prefix            = "${var.app_name}-${var.environment}"
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  alb_sg_id              = module.security.alb_sg_id
  health_check_path      = "/health"
}

# 6) ECS cluster + service
module "ecs" {
  source                       = "./modules/ecs"
  name_prefix                  = "${var.app_name}-${var.environment}"
  cluster_name                 = "${var.app_name}-${var.environment}-cluster"
  container_name               = var.app_name
  container_port               = var.container_port
  cpu                          = var.cpu
  memory                       = var.memory
  desired_count                = var.desired_count
  target_group_arn             = module.alb.target_group_arn
  vpc_id                       = module.network.vpc_id
  subnet_ids                   = var.place_tasks_in_private_subnets ? module.network.private_subnet_ids : module.network.public_subnet_ids
  service_sg_id                = module.security.service_sg_id
  assign_public_ip             = var.assign_public_ip
  execution_role_arn           = module.iam.execution_role_arn
  task_role_arn                = module.iam.task_role_arn
  log_retention_days           = 7
  ssm_secret_name              = var.ssm_secret_name
  ecr_repository_url           = module.ecr.repository_url
}

