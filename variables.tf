variable "deployment_name" {
  description = "A unique string to use for this module to make sure resources do not clash with others"
  type = string
}

variable "require_message" {
  description = "Whether a message is required as part of the contact form. In the case of a simple sign up form where only a name and email is requested, this would be set to false."
  type = bool
}

variable "access_control_allow_origin" {
  description = "CORS configuration for the API. This is a list of domains from which the API is allowed to be called, thereby defining when it correctly returns CORS headers."
  type = list(string)
}


variable "email_config" {
  description = "Optional. If provided, incoming forms will be forwarded by email to the given email addresses. You must have set up email or domain verification for the from_address in order for this to work."
  type = object({
    from_address = string
    to_addresses = list(string)
  })
  default = null
}

variable "alarm_sns_topic_arn" {
  description = "Optional. SNS topic to publish notifications to in the event of an error with the lambda function. If not provided, no alarm is created."
  type = string
  default = null
}

variable "additional_fields" {
  description = "List of required additional field names to collect"
  type = list(string)
  default = []
}

variable "optional_additional_fields" {
  description = "List of optional additional field names to collect"
  type = list(string)
  default = []
}
