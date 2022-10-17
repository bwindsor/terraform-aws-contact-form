/* Alarm for any error in the lambda function */
resource "aws_cloudwatch_metric_alarm" "lambda_function_has_errors" {
  count = var.alarm_sns_topic_arn == null ? 0 : 1

  alarm_name          = "${aws_lambda_function.lambda_function.function_name}-has-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  datapoints_to_alarm = "1"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  dimensions = {
    FunctionName = aws_lambda_function.lambda_function.function_name
  }
  period             = 300
  statistic          = "Sum"
  threshold          = "1"
  alarm_description  = "Alert if lambda function throws an error"
  alarm_actions      = [var.alarm_sns_topic_arn]
  ok_actions         = [var.alarm_sns_topic_arn]
  treat_missing_data = "notBreaching"
}
