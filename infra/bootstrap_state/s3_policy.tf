data "aws_iam_policy_document" "tfstate_bucket_policy" {
  statement {
    sid     = "ListStatePrefix"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_actions.arn]
    }

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${var.state_bucket_prefix_root}/*"]
    }
  }

  statement {
    sid     = "CRUDStateObjects"
    effect  = "Allow"
    actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject","s3:AbortMultipartUpload"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/${var.state_bucket_prefix_root}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.github_actions.arn]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = var.state_bucket_name
  policy = data.aws_iam_policy_document.tfstate_bucket_policy.json
}
