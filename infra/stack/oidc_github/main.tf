terraform {
  required_version = ">= 1.6.0"

  backend "s3" {
    bucket         = "tfstate-ml-sandbox"
    key            = "services/object-classifier/oidc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tfstate-ml-locks" # o warning depreciação pode ser ignorado por enquanto
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Debug: quem sou eu, e qual role a esteira assumiu?
data "aws_caller_identity" "me" {}

data "aws_iam_role" "github_deploy" {
  name = "github-ml-artifacts-deploy"
}

output "whoami_account" {
  value = data.aws_caller_identity.me.account_id
}

output "github_role_arn" {
  value = data.aws_iam_role.github_deploy.arn
}
