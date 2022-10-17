resource "random_id" "lambda_archive" {
  byte_length = 8
}

/* Zip files to be uploaded for lambda functions */
data "archive_file" "lambda_function" {
  type        = "zip"
  output_path = "${path.root}/.terraform/artifacts/${random_id.lambda_archive.hex}.zip"

  source {
    content  = file("${path.module}/lambda_post_contact_form.py")
    filename = "lambda_post_contact_form.py"
  }
}

resource "aws_lambda_function" "lambda_function" {
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
  function_name    = "${var.deployment_name}-post_contact_form"
  role             = aws_iam_role.iam_for_lambda_contact_form.arn
  handler          = "lambda_post_contact_form.handler"
  runtime          = "python3.9"
  timeout          = 5
  memory_size      = 256
  description      = "Handler for contact for being posted"
  environment {
    variables = {
      env = terraform.workspace
      DATABASE_TABLE_NAME = aws_dynamodb_table.data.name
      IS_MESSAGE_REQUIRED = var.require_message
      ACCESS_CONTROL_ALLOWED_ORIGINS = join(",", var.access_control_allow_origin)
      ENABLE_EMAIL_FORWARD = var.email_config != null
      FROM_EMAIL_ADDRESS = var.email_config == null ? "" : var.email_config.from_address
      TARGET_EMAIL_ADDRESSES = var.email_config == null ? "" : join(",", var.email_config.to_addresses)
    }
  }
}
