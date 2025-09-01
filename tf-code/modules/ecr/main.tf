resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"

  # Force enable secure defaults
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = { Name = var.repo_name }
}

# Lifecycle: purge dangling images to save on ECR costs
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images after N days",
        selection    = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = var.expire_untagged_after_days
        },
        action = { type = "expire" }
      }
    ]
  })
}

output "repository_url" { value = aws_ecr_repository.this.repository_url }
