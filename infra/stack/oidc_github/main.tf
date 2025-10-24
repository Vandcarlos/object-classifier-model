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
