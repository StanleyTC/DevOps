data "aws_iam_policy_document" "document" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rolelambda" {
  name = "${local.namespaced_service_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.document.json
}









data "aws_iam_policy_document" "policyapigateway" {
  statement {
    effect = "Allow"
    resources = ["*"] //all resources == *
    actions = [
        "dynamodb:ListTables",
        "ssm:DescribeParameters"
    ]
  }

  statement {
    effect = "Allow"
    resources = ["arn:aws:dynamodb:${var.aws_region}:${var.aws_account_id}:table/${aws_dynamodb_table.this.name}"]
    actions = [
        "dynamodb:PutItem",
        "dynamodb:DescribeTable",
        "dynamodb:DeleteItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem"
    ]
  }

    statement {
    effect = "Allow"
    resources = ["arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${aws_ssm_parameter.table.name}"]
    actions = [
        "ssm:GetParameters",
        "ssm:GetParameter"
    ]
  }
}

resource "aws_iam_policy" "policyfordatadynamo" {
  name = "${local.namespaced_service_name}-policy"
  policy = data.aws_iam_policy_document.policyapigateway.json
}

resource "aws_iam_role_policy_attachment" "policydynamo" {
  policy_arn = aws_iam_policy.policyfordatadynamo.arn
  role = aws_iam_role.rolelambda.name
}