resource "aws_dynamodb_table" "data" {
  name         = "${var.deployment_name}-contact-form"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"
  sort_key     = "submission_id"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "submission_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name = "${var.deployment_name}-contact-form"
  }
}
