resource "aws_iam_role" "role" {
  name = var.name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = var.service
        }
      },
    ]
  })

  managed_policy_arns = [aws_iam_policy.policy.arn]
}

data "aws_iam_policy_document" "policy-document" {
  statement {
    sid = "1"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      var.secretArn
    ]
  }

  statement {
    sid = "2"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]

    resources = [
      var.kmsArn
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"

      values = [
        "secretsmanager.us-east-1.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "policy" {
  name   = '${var.name}-policy'
  path   = "/"
  policy = data.aws_iam_policy_document.policy-document.json
}
