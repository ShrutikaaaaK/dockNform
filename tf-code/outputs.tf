output "alb_dns_name" { value = module.alb.alb_dns_name }
output "ecr_repository_url" { value = module.ecr.repository_url }
output "cluster_name" { value = module.ecs.cluster_name }
