data "aws_caller_identity" "me" {}

# 3.1 OIDC provider do GitHub (se já existir, pode importar)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # Thumbprint padrão do GitHub (pode mudar no futuro; monitore)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 3.2 Trust policy: permite que o GitHub Actions assuma o role via OIDC
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Você pode ser específico com sub, ou amplo (durante setup use o amplo)
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.repo_owner}/${var.repo_name}:*", # amplo e prático
        # Se preferir granular:
        # "repo:${var.repo_owner}/${var.repo_name}:ref:refs/heads/main",
        # "repo:${var.repo_owner}/${var.repo_name}:workflow_dispatch",
        # "repo:${var.repo_owner}/${var.repo_name}:pull_request",
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.github_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  # Opcional: boundary/tags
  tags = {
    Project = var.repo_name
    Purpose = "Terraform-OIDC"
  }
}

# 3.3 Policy: S3 backend (bucket + prefixo)
data "aws_iam_policy_document" "backend_s3" {
  statement {
    sid     = "ListStatePrefix"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.state_bucket_prefix_root}/*"]
    }
  }

  statement {
    sid     = "BucketReadMetadataAll"
    effect  = "Allow"
    actions = [
      "s3:GetBucket*",
      "s3:GetEncryptionConfiguration",
      "s3:GetPublicAccessBlock",
      "s3:GetAccelerateConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration"
    ]
    resources = [
      "arn:aws:s3:::ml-artifacts-*",
      "arn:aws:s3:::tfstate-ml-*"
    ]
  }

  statement {
    sid     = "CRUDStateObjects"
    effect  = "Allow"
    actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:AbortMultipartUpload"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/${var.state_bucket_prefix_root}/*"]
  }
}

resource "aws_iam_policy" "backend_s3" {
  name   = "${var.github_role_name}-backend-s3"
  policy = data.aws_iam_policy_document.backend_s3.json
}

resource "aws_iam_role_policy_attachment" "attach_backend_s3" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.backend_s3.arn
}

# 3.4 Policy: DynamoDB lock
data "aws_iam_policy_document" "dynamodb_lock" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable",
    ]
    resources = ["arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.me.account_id}:table/${var.lock_table_name}"]
  }
}

resource "aws_iam_policy" "dynamodb_lock" {
  name   = "${var.github_role_name}-tf-lock"
  policy = data.aws_iam_policy_document.dynamodb_lock.json
}

resource "aws_iam_role_policy_attachment" "attach_dynamodb_lock" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.dynamodb_lock.arn
}
