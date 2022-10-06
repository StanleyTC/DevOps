resource "aws_ssm_parameter" "table" {
  name = local.namespaced_service_name
  type = "String"
  value = aws_dynamodb_table.this.name
}