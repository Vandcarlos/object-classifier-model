provider "aws" { region = "us-east-1" }

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:Vandcarlos/object-classifier-model:ref:refs/heads/main",
        "repo:Vandcarlos/object-classifier-model:ref:refs/tags/*"
      ]
    }
  }
}

resource "aws_iam_policy" "boundary" {
  name = "permissions-boundary-github-ml"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : ["s3:*"],
        "Resource" : [
          "arn:aws:s3:::ml-artifacts-*",
          "arn:aws:s3:::ml-artifacts-*/*",
          "arn:aws:s3:::tfstate-ml-*",
          "arn:aws:s3:::tfstate-ml-*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : ["cloudfront:CreateInvalidation"],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["dynamodb:*"],
        "Resource" : "arn:aws:dynamodb:*:*:table/tfstate-ml-locks"
      },
      {
        "Effect" : "Deny",
        "Action" : [
          "iam:CreateUser",
          "iam:CreateAccessKey",
          "iam:AttachUserPolicy",
          "iam:PutUserPolicy"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "github_deploy" {
  name                 = "github-ml-artifacts-deploy"
  assume_role_policy   = data.aws_iam_policy_document.assume_role.json
  permissions_boundary = aws_iam_policy.boundary.arn
}

resource "aws_iam_policy" "github_policy" {
  name = "github-ml-artifacts-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::ml-artifacts-*",
          "arn:aws:s3:::ml-artifacts-*/*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : ["cloudfront:CreateInvalidation"],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ],
        "Resource" : "arn:aws:dynamodb:*:*:table/tfstate-ml-locks"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = aws_iam_policy.github_policy.arn
}

output "github_role_arn" {
  value = aws_iam_role.github_deploy.arn
}
