variable "env" {
  type        = string
  description = "The name of the environment"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the Amazon S3 bucket that will be created. This will be used to store the Terraform state files and also the AWS CodePipeline artifacts."
}

variable "dynamodb_lock_table_name" {
  type        = string
  description = "Name of the DynamoDB table where Terraform state file locks will be stored"
}
