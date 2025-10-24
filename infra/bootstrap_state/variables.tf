variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "repo_owner" {
  type    = string
  default = "Vandcarlos" # ajuste se mudar o owner
}

variable "repo_name" {
  type    = string
  default = "object-classifier-model"
}

variable "github_role_name" {
  type    = string
  default = "github-ml-artifacts-deploy"
}

variable "state_bucket_name" {
  type    = string
  default = "tfstate-ml-sandbox"
}

variable "state_bucket_prefix" {
  type    = string
  default = "services/object-classifier/oidc"
}

variable "lock_table_name" {
  type    = string
  default = "tfstate-ml-locks"
}