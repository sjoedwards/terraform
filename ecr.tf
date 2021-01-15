# Create ECR Repo
resource "aws_ecr_repository" "ecr_repo_app" {
  name = "sjoedwards-ecr-demo" # Naming my repository
}

# Create ECR Repo
resource "aws_ecr_repository" "ecr_repo_nginx" {
  name = "sjoedwards-ecr-nginx" # Naming my repository
}
