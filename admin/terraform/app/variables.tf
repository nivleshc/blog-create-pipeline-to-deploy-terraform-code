variable "env" {
  description = "The environment name for this deployment"
}

variable "project_name" {
  description = "The name of the project"
}

variable "region" {
  description = "The AWS region where all resources will be deployed"
  default     = "ap-southeast-2"
}

variable "s3_bucket_name" {
  description = "The name of the Amazon S3 bucket where the terraform state files are stored."
}

variable "s3_bucket_key_prefix" {
  description = "The folder name inside which the terraform state files are stored."
}

variable "s3_bucket_key" {
  description = "The name of the terraform state file"
  default     = "terraform.tfstate"
}

variable "dynamodb_lock_table_name" {
  description = "The name of the DynamoDB table name that is used to manage concurrent access to terraform state files."
}