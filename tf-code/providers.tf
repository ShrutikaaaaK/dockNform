provider "aws" {
  region = var.aws_region
  default_tags = {
    Project     = "ecs-fargate-demo"
    Environment = var.environment
    Owner       = var.owner
  }
}
