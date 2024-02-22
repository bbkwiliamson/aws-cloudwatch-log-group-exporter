resource aws_cloudwatch_event_rule sadigitalLogGroups_exporter {
  name                = "sadigitalLogGroups_exporter"
  description         = "Fires periodically to export logs to S3"
  schedule_expression = "rate(4 hours)"
}

resource aws_cloudwatch_event_target sadigitalLogGroups_exporter {
  rule      = aws_cloudwatch_event_rule.sadigitalLogGroups_exporter.name
  target_id = "sadigitalLogGroups-exporter"
  arn       = aws_lambda_function.sadigitalLogGroups_exporter.arn
}

resource aws_lambda_permission sadigitalLogGroups-exporter {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sadigitalLogGroups_exporter.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.sadigitalLogGroups_exporter.arn
}
