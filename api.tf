locals {
  api_spec = templatefile("${path.module}/api_spec.yaml", {
    lambda_post_contact_form_invoke_arn =  aws_lambda_function.lambda_function.arn
  })
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.deployment_name}-contact-form-api"
  version = "1.0"
  description = "Contact form API"

  protocol_type = "HTTP"
  body = local.api_spec
}

resource "aws_apigatewayv2_stage" "gateway_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id
  name   = "prod"
  auto_deploy = true
}

# Resource policy on lambda function to allow invocation by API gateway
resource "aws_lambda_permission" "allow_api_gateway_to_invoke_lambda" {
  statement_id  = "${var.deployment_name}-GatewayInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*"
}

output "api_id" {
  value = aws_apigatewayv2_api.api_gateway.id
}
output "stage_id" {
  value = aws_apigatewayv2_stage.gateway_stage.id
}
