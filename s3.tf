resource aws_s3_bucket sadigitalcloudwatch_logs_export_bucket {
  bucket = var.bucket_name
  tags   = var.tags
 

  server_side_encryption_configuration {
   rule {
     apply_server_side_encryption_by_default {
       kms_master_key_id = var.kms_key_arn
       sse_algorithm = "aws:kms"
      }
    }
 
  }

   lifecycle_rule {
    id = "ARCHIVING"
    enabled = true
 
    transition { 
      days = 90 
      storage_class = "STANDARD_IA"
    }
    transition {
      days = 120
      storage_class = "GLACIER_IR" 
    }
  }
}

resource aws_s3_bucket_policy main {
  bucket = aws_s3_bucket.sadigitalcloudwatch_logs_export_bucket.id
  policy = data.aws_iam_policy_document.main.json
}

data aws_iam_policy_document main {
  statement {
    effect  = "Allow"
    actions = [ "s3:GetBucketAcl",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject"]
    principals {
      type        = "Service"
      identifiers = [
        "logs.amazonaws.com"
      ]
    }
    resources = [
     "${aws_s3_bucket.sadigitalcloudwatch_logs_export_bucket.arn}",
     "${aws_s3_bucket.sadigitalcloudwatch_logs_export_bucket.arn}/*"
    ]
  }
}
