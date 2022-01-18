// IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_snapshot_and_restore_rds_db_role"
  assume_role_policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Action":"sts:AssumeRole",
      "Principal": {
      "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
  EOF
}

resource "aws_iam_policy" "lambda_logging" {
  name = "lambda_logging"
  path = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_role_managed_policy_attachment" {
  count = length(var.managed_policies_for_lambdas)
  policy_arn = element(var.managed_policies_for_lambdas, count.index)
  role = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_role_logs_policy_attachment" {
  role = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}


resource "aws_lambda_function" "rds_snapshot_and_restore_lambda" {
  function_name = var.lambda_function_name
  role = aws_iam_role.lambda_role.arn
  filename = "rds_instance.zip"
  handler = join(".", ["rds_instance","lambda_handler"])
  runtime = "python3.9"
  timeout  = "900"

  depends_on = [
    aws_iam_role_policy_attachment.lambda_role_managed_policy_attachment,
    aws_iam_role_policy_attachment.lambda_role_logs_policy_attachment,
    aws_cloudwatch_log_group.lambda_log_group
  ]
}