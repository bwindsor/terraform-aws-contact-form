output "contact_form_post_url" {
  description = "URL to POST contact form requests to"
  value = "${aws_apigatewayv2_stage.gateway_stage.invoke_url}/contactform"
}
