data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "codepipeline_artifacts_s3_bucket" {
  bucket = var.codepipeline_artifacts_s3_bucket_name
}

# create a KMS customer managed key that will be used to encrypt the codepipeline artifacts
resource "aws_kms_key" "codepipeline_kms_key" {
  description = "KMS key used by ${var.project_name}-${var.env} CodePipeline pipeline"
}

# create an alias for the customer managed KMS key
resource "aws_kms_alias" "codepipeline_kms_key_alias" {
  name          = "alias/${var.project_name}-${var.env}"
  target_key_id = aws_kms_key.codepipeline_kms_key.id
}