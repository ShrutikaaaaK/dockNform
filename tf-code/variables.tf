variable "aws_region"    { type = string  default = "ap-south-1" }
variable "environment"   { type = string  default = "dev" }
variable "owner"         { type = string  default = "devops" }
variable "app_name"      { type = string  default = "hello-node" }
variable "container_port"{ type = number  default = 3000 }
variable "desired_count" { type = number  default = 1 }
variable "cpu"           { type = number  default = 256 }    # 0.25 vCPU
variable "memory"        { type = number  default = 512 }    # 0.5 GB

# Networking toggles / CIDRs
variable "vpc_cidr"      { type = string  default = "10.0.0.0/16" }
variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "enable_nat"    { type = bool    default = false }  # cost saver OFF by default
variable "alb_ingress_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"] # lock this to corp IPs for prod
}

# Service placement
variable "place_tasks_in_private_subnets" { type = bool default = false } # cost-friendly default
variable "assign_public_ip"               { type = bool default = true }  # needed if using public subnets only

# Dummy secret name (create in SSM Parameter Store as SecureString)
variable "ssm_secret_name" { type = string default = "/demo/secret" }

# ECR repo name
variable "ecr_repo_name"  { type = string default = "hello-node" }
