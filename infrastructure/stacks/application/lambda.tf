module "data_model_ui_lambda" {
  source        = "../../modules/lambda"
  function_name = "${local.prefix}-lambda${local.workspace_suffix}"
  timeout       = var.data_model_ui_db_connection_timeout
  memory_size   = var.data_model_ui_memory_size

  subnet_ids           = [for subnet in data.aws_subnet.private_subnets_details : subnet.id]
  security_group_ids   = [aws_security_group.data_model_ui_sg.id]
  lambda_s3_bucket     = data.aws_s3_bucket.artefact_bucket.bucket
  lambda_s3_bucket_arn = data.aws_s3_bucket.artefact_bucket.arn
  lambda_s3_key        = "${local.prefix}-lambda/${local.prefix}-lambda-${var.application_tag}.zip"
  lambda_layer_name    = "${local.prefix}-layer${local.workspace_suffix}"
  lambda_layer_s3_key  = "${local.prefix}-layer/${local.prefix}-layer-${var.application_tag}.zip"

  lambda_handler = var.data_model_ui_lambda_handler
  lambda_runtime = var.data_model_ui_lambda_runtime

  env_vars = {
    "DYNAMODB_HOST" = "UPDATE_ME"
  }
}

resource "aws_lambda_function_url" "data_model_ui" {
  function_name      = module.data_model_ui_lambda.function_name
  authorization_type = "NONE"
}
