provider "aws" {
  region = "us-east-1"
}

# Debug: quem sou eu, e qual role a esteira assumiu?
data "aws_caller_identity" "me" {}

output "whoami_account" {
  value = data.aws_caller_identity.me.account_id
}
