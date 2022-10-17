output "contact_form_post_url" {
  description = "URL to POST contact form requests to"
  value = "${aws_apigatewayv2_stage.gateway_stage.invoke_url}/contactform"
}

output "api_endpoint" {
  description = "Base URL for the created API. Can be useful for CORS configuration."
  value = aws_apigatewayv2_api.api_gateway.api_endpoint
}