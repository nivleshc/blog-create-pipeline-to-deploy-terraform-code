output "s3_bucket_name" {
  description = "Name of the Amazon S3 bucket that was created"
  value       = aws_s3_bucket.s3bucket.id
}

output "dynamodb_table_name" {
  description = "Name of the Amazon DynamoDB table that was craated"
  value       = aws_dynamodb_table.terraform-lock-table.name
}

output "kms_key_alias" {
  description = "The alias for the Amazon KMS CMK that was created"
  value       = aws_kms_alias.alias.name
}