terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
  }
  required_version = "= 1.9.0"
}

module "migration_base" {
  source = "git::ssh://git@atc-github.azure.cloud.bmw/DBOINV/conveh_cdh_sdwh_migration_base.git?ref=0.8.0"
  stage  = var.stage
  hub    = var.hub
}

# Create ZIP file
data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = "../../../code/trigger_glue_job.py"
  output_path = "../../../code/trigger_glue_job.zip"
}

# Lambda for Glue jobs
resource "aws_lambda_function" "gdpr_lambda" {
  function_name    = "trigger-glue-job-from_s3"
  runtime          = "python3.9"
  handler          = "trigger_glue_job.lambda_handler"
  role             = "arn:aws:iam::066991206117:role/service-role/trigger-glue-job-on-upload-role-37y7e5c0"
  filename         = data.archive_file.lambda_package.output_path
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = {
      S3_BUCKET_NAME = aws_s3_bucket.gdpr_bucket.id
    }
  }

  timeout = 900
  depends_on = [aws_s3_bucket.gdpr_bucket]
}

# S3 Bucket for GDPR
resource "aws_s3_bucket" "gdpr_bucket" {
  bucket = "gdpr-job-bucket"

  tags = {
    Name        = "GDPR Deletion Bucket"
    Environment = var.stage
  }
}

# S3 Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "gdpr_bucket_lifecycle" {
  bucket = aws_s3_bucket.gdpr_bucket.id

  rule {
    id     = "expire-objects"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

# S3 to Invoke Lambda
resource "aws_lambda_permission" "s3_invoke_lambda" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gdpr_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.gdpr_bucket.arn
}

# S3 Event Notification to Trigger Lambda
resource "aws_s3_bucket_notification" "gdpr_lambda_trigger" {
  bucket = aws_s3_bucket.gdpr_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.gdpr_lambda.arn
    events = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }
}


# Deperso
module "gdpr_deperso_job" {
  source = "git::ssh://git@atc-github.azure.cloud.bmw/cdec/cdec-iceberg-batch-blueprint.git//glue?ref=1.4.1"

  stage = var.stage
  hub   = var.hub
  tags  = local.tags

  module_name = "${var.module_name}_deperso"

  vpc_name         = var.vpc_name
  vpc_subnet_index = var.vpc_subnet_index

  enable_alerts            = var.enable_alerts
  sns_topic_for_alerts_arn = module.migration_base.sns_topic_for_alerts_arn

  code_repo_bucket             = module.migration_base.code_repo_bucket
  code_repo_bucket_kms_key_arn = module.migration_base.sdwh_migration_kms_key_arn

  use_lineage                = false
  pseudonymizer_api_key_name = var.pseudonymizer_api_key_name

  custom_files_folder_name = local.custom_files_folder_name_path


  job_definitions = [
    {
      job_name = "${var.module_name}_deperso",
      job = {
        source_datasets = [
          {
            source_dataset_type = var.source_dataset_type,
            dataset             = "vehicle_key_src",
            tables = file("${path.root}/table_settings/config_source_table_gdpr.json")
          }
        ]
        transformations = [
          {
            dataset = "vehicle_key_d_pre",
            tables = file("${path.root}/table_settings/config_transformation_workflow_deperso.json")
          }
        ]
      }
    }
  ]
}

# Perso
module "gdpr_perso_job" {
  source = "git::ssh://git@atc-github.azure.cloud.bmw/cdec/cdec-iceberg-batch-blueprint.git//glue?ref=1.4.1"

  stage = var.stage
  hub   = var.hub
  tags  = local.tags

  module_name = "${var.module_name}_perso"

  vpc_name         = var.vpc_name
  vpc_subnet_index = var.vpc_subnet_index

  enable_alerts            = var.enable_alerts
  sns_topic_for_alerts_arn = module.migration_base.sns_topic_for_alerts_arn

  code_repo_bucket             = module.migration_base.code_repo_bucket
  code_repo_bucket_kms_key_arn = module.migration_base.sdwh_migration_kms_key_arn

  use_lineage                = false
  pseudonymizer_api_key_name = var.pseudonymizer_api_key_name

  custom_files_folder_name = local.custom_files_folder_name_path


  job_definitions = [
    {
      job_name = "${var.module_name}_perso",
      job = {
        source_datasets = [
          {
            source_dataset_type = var.source_dataset_type,
            dataset             = "vehicle_key_src",
            tables = file("${path.root}/table_settings/config_source_table_gdpr.json")
          }
        ]
        transformations = [
          {
            dataset = "vehicle_key_p_pre",
            tables = file("${path.root}/table_settings/config_transformation_workflow_perso.json")
          }
        ]
      }
    }
  ]
}

# Deletion
module "gdpr_deletion_job" {
  source = "git::ssh://git@atc-github.azure.cloud.bmw/cdec/cdec-iceberg-batch-blueprint.git//glue?ref=1.4.1"

  stage = var.stage
  hub   = var.hub
  tags  = local.tags

  module_name = "${var.module_name}_deletion"

  vpc_name         = var.vpc_name
  vpc_subnet_index = var.vpc_subnet_index

  enable_alerts            = var.enable_alerts
  sns_topic_for_alerts_arn = module.migration_base.sns_topic_for_alerts_arn

  code_repo_bucket             = module.migration_base.code_repo_bucket
  code_repo_bucket_kms_key_arn = module.migration_base.sdwh_migration_kms_key_arn

  use_lineage                = false
  pseudonymizer_api_key_name = var.pseudonymizer_api_key_name

  custom_files_folder_name = local.custom_files_folder_name_path


  job_definitions = [
    {
      job_name = "${var.module_name}_deletion",
      job = {
        source_datasets = [
          {
            source_dataset_type = var.source_dataset_type,
            dataset             = "vehicle_key_src",
            tables = file("${path.root}/table_settings/config_source_table_del.json")
          }
        ]
        transformations = [
          {
            dataset = "vehicle_key_src",
            tables = file("${path.root}/table_settings/config_transformation_workflow_deletion.json")
          }
        ]
      }
    }
  ]
}