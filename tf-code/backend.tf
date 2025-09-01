
terraform {
  backend "s3" {
    bucket         = "my-tfstate-bucket"
    key            = "ecs-fargate-demo/${env}.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
