variable "env" {
  type        = string
  description = "The name of the environment where this project is being run. eg dev, test, preprod, prod."
}

variable "project_name" {
  type        = string
  description = "The name of the project"
}

variable "infra_approver_email" {
  type        = string
  description = "Infrastructure change request approver's email address."
}

variable "app_approver_email" {
  type        = string
  description = "Application change request approver's email address."
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the Amazon S3 bucket where Terraform state file will be stored"
}

variable "s3_bucket_key_prefix" {
  description = "Key prefix inside which the Terraform state file will be stored in the Amazon S3 bucket"
}

variable "dynamodb_lock_table_name" {
  type        = string
  description = "The name of the Amazon DynamoDB table that will be used for storing terraform state locks"
}

variable "codecommit_infra_repo_default_branch_name" {
  type        = string
  description = "The default branch for the infrastructure AWS CodeCommit repo"
}

variable "codecommit_app_repo_default_branch_name" {
  type        = string
  description = "The default branch for the application AWS CodeCommit repo"
}

variable "codecommit_compute_type" {
  type        = string
  description = "The compute type for the codebuild project"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "codecommit_container_image_name" {
  type        = string
  description = "The container image to use for the codebuild project"
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
}

variable "codecommit_container_type" {
  type        = string
  description = "The container type to use for the codebuild project"
  default     = "LINUX_CONTAINER"
}
variable "codepipeline_artifacts_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket where CodePipeline will store its artifacts"
}

variable "codepipeline_artifacts_s3_bucket_kms_key_alias" {
  type        = string
  description = "The alias for the KMS CMK that is used to encrypt the objects in the S3 bucket"
}