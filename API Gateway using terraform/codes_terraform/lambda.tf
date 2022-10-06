data "archive_file" "zipfile" {
  output_path = "files/utils_layers.zip"
  type = "zip"
  source_dir = "${local.layers_path}/utils"
}

resource "aws_lambda_layer_version" "layerlamb" {
  layer_name = "layerForLambda"
  description = "layer created for lambdas"
  filename = data.archive_file.zipfile.output_path
  source_code_hash = data.archive_file.zipfile.output_base64sha256
  compatible_runtimes = ["nodejs14.x"]
}

data "archive_file" "zipfileslambda" {
  for_each = local.lambdas
  output_path = "files/${each.key}.zip"
  type = "zip"
  source_file = "${local.lambdas_path}/functions/${each.key}.js"
}


resource "aws_lambda_function" "awsfunction" {
  for_each = local.lambdas
  function_name = each.key
  handler = "${each.key}.handler"
  description = each.value["description"]
  role = aws_iam_role.rolelambda.arn
  runtime = "nodejs14.x"
  filename = data.archive_file.zipfileslambda[each.key].output_path
  source_code_hash = data.archive_file.zipfileslambda[each.key].output_base64sha256
  timeout = each.value["timeout"]
  memory_size = each.value["memory"]
  layers = [aws_lambda_layer_version.layerlambd.arn]
  environment {
    variables = {
        TABLE = aws_ssm_parameter.table.name
        DEBUG = var.env == "dev"
    }
  }
}

resource "aws_lambda_permission" "name" {
  for_each = local.lambdas
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.awsfunction[each.key].arn
  statement_id = "AllowExecutionFromAPIGateway"
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}