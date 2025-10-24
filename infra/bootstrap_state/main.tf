terraform {
  required_version = ">= 1.6.0"
}

# outputs consolidados (só pra facilitar visualização)
output "github_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "bucket_policy_id" {
  value = aws_s3_bucket_policy.tfstate.id
}

output "policies_attached" {
  value = [
    aws_iam_policy.backend_s3.name,
    aws_iam_policy.dynamodb_lock.name
  ]
}
