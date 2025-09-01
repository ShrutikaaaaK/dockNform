# Execution role: pull from ECR, write logs
data "aws_iam_policy_document" "execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.name_prefix}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.execution_assume.json
}

resource "aws_iam_role_policy_attachment" "exec_ecr" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task role: least privilege to read one SSM param
data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] }
  }
}

resource "aws_iam_role" "task" {
  name               = "${var.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

data "aws_iam_policy_document" "ssm_read_one" {
  statement {
    sid       = "ReadSingleParam"
    actions   = ["ssm:GetParameter", "ssm:GetParameters", "ssm:GetParameterHistory"]
    resources = [var.ssm_parameter_arn]
  }
}

resource "aws_iam_policy" "ssm_read" {
  name   = "${var.name_prefix}-ssm-read"
  policy = data.aws_iam_policy_document.ssm_read_one.json
}

resource "aws_iam_role_policy_attachment" "task_ssm" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.ssm_read.arn
}

# Strong password policy for IAM users
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length    = 14
  require_uppercase_characters = true
  require_lowercase_characters = true
  require_symbols             = true
  require_numbers             = true
  max_password_age            = 90
  password_reuse_prevention   = 24
  hard_expiry                 = true
}

output "execution_role_arn" { value = aws_iam_role.execution.arn }
output "task_role_arn"      { value = aws_iam_role.task.arn }
