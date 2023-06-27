output "codepipeline_artifacts_s3_bucket" {
  description = "Name of the Amazon S3 bucket that will contain the AWS CodePipeline artifacts"
  value       = var.codepipeline_artifacts_s3_bucket_name
}

output "codepipeline_kms_key_alias" {
  description = "The alias for the AWS KMS Key that is used to encrypt the AWS CodePipeline artifacts"
  value       = aws_kms_alias.codepipeline_kms_key_alias.name
}