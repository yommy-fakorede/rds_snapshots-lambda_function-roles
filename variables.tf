variable "lambda_function_name" {
  default = "rds_snapshot_and_restore_lambda"
}

variable "managed_policies_for_lambdas" {
  default = [
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  ]
}