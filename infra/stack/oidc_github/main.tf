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
     # --- S3: nível de BUCKET (listar e ler metadados do bucket) ---
			{
			  "Effect": "Allow",
			  "Action": [
			    "s3:ListBucket",
			    "s3:GetBucketLocation",
			    "s3:GetBucketVersioning",
			    "s3:PutBucketPolicy"    // necessário p/ aplicar a bucket policy do OAC no artifacts
			  ],
			  "Resource": [
			    "arn:aws:s3:::ml-artifacts-*",
			    "arn:aws:s3:::tfstate-ml-*"
			  ]
			},
			# --- S3: nível de OBJETO (state + artefatos) ---
			{
			  "Effect": "Allow",
			  "Action": [
			    "s3:GetObject",
			    "s3:PutObject",
			    "s3:DeleteObject"
			  ],
			  "Resource": [
			    "arn:aws:s3:::ml-artifacts-*/*",
			    "arn:aws:s3:::tfstate-ml-*/*"
			  ]
			},
			{
			  "Effect":"Allow",
			  "Action":[
			    "cloudfront:CreateDistribution",
			    "cloudfront:UpdateDistribution",
			    "cloudfront:GetDistribution",
			    "cloudfront:ListDistributions",
			    "cloudfront:TagResource",
			    "cloudfront:CreateOriginAccessControl",
			    "cloudfront:UpdateOriginAccessControl",
			    "cloudfront:GetOriginAccessControl",
			    "cloudfront:ListOriginAccessControls"
			  ],
			  "Resource":"*"
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
      # --- S3: nível de BUCKET (listar e ler metadados do bucket) ---
			{
			  "Effect": "Allow",
			  "Action": [
			    "s3:ListBucket",
			    "s3:GetBucketLocation",
			    "s3:GetBucketVersioning",
			    "s3:PutBucketPolicy"    // necessário p/ aplicar a bucket policy do OAC no artifacts
			  ],
			  "Resource": [
			    "arn:aws:s3:::ml-artifacts-*",
			    "arn:aws:s3:::tfstate-ml-*"
			  ]
			},
			# --- S3: nível de OBJETO (state + artefatos) ---
			{
			  "Effect": "Allow",
			  "Action": [
			    "s3:GetObject",
			    "s3:PutObject",
			    "s3:DeleteObject"
			  ],
			  "Resource": [
			    "arn:aws:s3:::ml-artifacts-*/*",
			    "arn:aws:s3:::tfstate-ml-*/*"
			  ]
			},
      {
			  "Effect":"Allow",
			  "Action":[
			    "cloudfront:CreateDistribution",
			    "cloudfront:UpdateDistribution",
			    "cloudfront:GetDistribution",
			    "cloudfront:ListDistributions",
			    "cloudfront:TagResource",
			    "cloudfront:CreateOriginAccessControl",
			    "cloudfront:UpdateOriginAccessControl",
			    "cloudfront:GetOriginAccessControl",
			    "cloudfront:ListOriginAccessControls"
			  ],
			  "Resource":"*"
			},
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
					"dynamodb:DescribeTable",
					"dynamodb:DeleteItem"
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
