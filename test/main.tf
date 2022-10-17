provider "aws" {
  region = "eu-west-1"
}

module "test_contact_form_backend" {
  source = "../."
  access_control_allow_origin = []
  deployment_name = ""
  require_message = false
  email_config = {
    from_address = ""
    to_addresses = "a,b"
  }
  alarm_sns_topic_arn = ""
}
