variable "name_prefix"            { type = string }
variable "cluster_name"           { type = string }
variable "container_name"         { type = string }
variable "container_port"         { type = number }
variable "cpu"                    { type = number }
variable "memory"                 { type = number }
variable "desired_count"          { type = number }
variable "target_group_arn"       { type = string }
variable "vpc_id"                 { type = string }
variable "subnet_ids"             { type = list(string) }
variable "service_sg_id"          { type = string }
variable "assign_public_ip"       { type = bool }
variable "execution_role_arn"     { type = string }
variable "task_role_arn"          { type = string }
variable "log_retention_days"     { type = number default = 7 }
variable "ssm_secret_name"        { type = string }
variable "ecr_repository_url"     { type = string }
