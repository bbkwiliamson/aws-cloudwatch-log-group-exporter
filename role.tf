resource aws_iam_role BoundedLogGroups_exporter {
  path                 = "/"
  name                 = "BoundedLogGroups_exporter_${var.region_shorthand == "" ? "" : "${var.region_shorthand}_"}${var.env}"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/BoundedPermissionsPolicy"
  assume_role_policy   = data.aws_iam_policy_document.lambda_assume.json
  tags                 = var.tags
}

resource aws_iam_role_policy_attachment BoundedLogGroups_exporter {
  role =  aws_iam_role.BoundedLogGroups_exporter.name
  policy_arn =  aws_iam_policy.BoundedLogGroups_exporter.arn
}

resource aws_iam_policy BoundedLogGroups_exporter {
  name        = "BoundedLogGroups_exporter_${var.region_shorthand == "" ? "" : "${var.region_shorthand}_"}${var.env}"
  policy      = data.aws_iam_policy_document.BoundedLogGroups_exporter.json
}

data aws_iam_policy_document lambda_assume {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com","logs.amazonaws.com","s3.amazonaws.com"]
    }
  }
}


data aws_iam_policy_document BoundedLogGroups_exporter {
  statement {  
    sid = "1"
    effect = "Allow"
    actions = [
      "logs:PutRetentionPolicy",
      "logs:PutLogEvents",
      "logs:ListTagsLogGroup",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:CreateExportTask",
      "logs:DescribeExportTasks",
      "ssm:PutParameter",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter",
      "ssm:DescribeParameters",
      "ssm:DeleteParameter",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetBucketAcl",
      "s3:CreateBucket",
      "s3:PutObjectACL",
      "s3:PutBucketAcl"
    ]
    resources = ["*"]
  }
}  
    
