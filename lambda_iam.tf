data "aws_iam_policy_document" "assume-lambda-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role" "iam_for_lambda_contact_form" {
  name               = "${var.deployment_name}-lambda-contact-form"
  assume_role_policy = data.aws_iam_policy_document.assume-lambda-role-policy.json
}
resource "aws_iam_role_policy_attachment" "lambda_contact_form_logging_attachment" {
  policy_arn = aws_iam_policy.lambda_log_policy.arn
  role       = aws_iam_role.iam_for_lambda_contact_form.name
}
resource "aws_iam_role_policy_attachment" "lambda_contact_form_ses_access" {
  policy_arn = aws_iam_policy.ses_send_policy.arn
  role       = aws_iam_role.iam_for_lambda_contact_form.name
}
resource "aws_iam_role_policy_attachment" "lambda_contact_form_dynamo_access" {
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  role       = aws_iam_role.iam_for_lambda_contact_form.name
}

resource "aws_iam_policy" "lambda_log_policy" {
  name        = "${var.deployment_name}-lambda_log_policy"
  description = "Policy to allow lambda to do logging"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ses_send_policy" {
  name        = "${var.deployment_name}-lambda-ses-send"
  description = "Allow lambda to send messages via SES"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "ses:SendEmail"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "${var.deployment_name}-dynamodb"
  description = "Allow write only access to DynamoDb by contact form"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Action : [
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:PutItem",
          "dynamodb:ConditionCheckItem",
        ],
        Resource : "${aws_dynamodb_table.data.arn}*"
      }
    ]
  })
}