resource "aws_apigatewayv2_api" "this" {
  name = "${local.namespaced_service_name}-api"
  protocol_type = "HTTP"
} //api gateway

resource "aws_apigatewayv2_stage" "this" {
    api_id = aws_apigatewayv2_api.this.id
    name = "$default"
    auto_deploy = true
}

resource "aws_apigatewayv2_integration" "users_integration" {
  for_each = local.lambdas //integration lambdas with api gateway

  api_id = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri = aws_lambda_function.awsfunction[each_key].invoke_arn
}

resource "aws_apigatewayv2_route" "users" { //creation of 4 users refering to lambda
  for_each = local.paths

  api_id = aws_apigatewayv2_api.this.id
  route_key = "${upper(each.key)} /users"
  target = "integrations/${aws_apigatewayv2_integration.users_integration[each.key].id}"
}

resource "aws_apigatewayv2_route" "users" { //route get -- id --
  api_id = aws_apigatewayv2_api.this.id
  route_key = "GET /users/{id}"
  target = "integrations/${aws_apigatewayv2_integration.users_integration["get"].id}"
}