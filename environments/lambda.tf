data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.db.arn,
    ]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy" "lambda_inline_policy" {
  name   = "lambda_dynamodb_access"
  role   = aws_iam_role.iam_for_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "../src/back/lambda_function.py"
  output_path = "../src/back/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "dor-resume"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_permission" "apigw_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
