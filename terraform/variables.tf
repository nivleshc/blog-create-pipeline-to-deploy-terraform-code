variable "env" {
  type        = string
  description = "The name of the environment where this project is being run. eg dev, test, preprod, prod."
}

variable "project" {
  type        = string
  description = "The name of the project"
}

variable "owner_email" {
  type = string
  description = "Owner's email address. This will be subscribed to the sns topic that will receive approval requests"
}

variable "dynamodb_lock_table_name" {
  type        = string
  description = "The name of the Amazon DynamoDB table that will be used for storing terraform state locks"
}

variable "codepipeline_artifacts_s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket where CodePipeline will store its artifacts"
}

variable "codepipeline_artifacts_s3_bucket_kms_key_alias" {
  type        = string
  description = "The alias for the KMS CMK that is used to encrypt the objects in the S3 bucket"
}

variable "codecommit_infra_repo_name" {
  type        = string
  description = "The name of the infrastructure AWS CodeCommit repository."
}

variable "codecommit_infra_repo_default_branch_name" {
  type        = string
  description = "The default branch for the infrastructure AWS CodeCommit repo"
}

variable "codecommit_app_repo_name" {
  type        = string
  description = "The name of the application AWS CodeCommit repository."
}

variable "codecommit_app_repo_default_branch_name" {
  type        = string
  description = "The default branch for the application AWS CodeCommit repo"
}

variable "codebuild_project_name_prefix" {
  type        = string
  description = "The prefix that will be used for the AWS CodeBuild project name"
}

variable "codebuild_service_role_name" {
  type        = string
  description = "The name of the AWS CodeBuild Project's service role"
}

variable "codebuild_cloudwatch_logs_group_name" {
  type        = string
  description = "The cloudwatch logs group name for CodeBuild"
}

variable "codebuild_cloudwatch_logs_stream_name" {
  type        = string
  description = "The cloudwatch logs stream name for CodeBuild"
}

variable "codepipeline_pipeline_name" {
  type        = string
  description = "The name of the AWS CodePipeline pipeline"
}

variable "codepipeline_role_name" {
  type        = string
  description = "The name of the AWS CodePipeline role"
}

variable "codepipeline_role_policy_name" {
  type        = string
  description = "The name of the AWS CodePipeline role policy"
}

variable "cloudwatch_events_role_name" {
  type        = string
  description = "The name for the AWS CloudWatch Events role policy"
}

variable "cloudwatch_events_role_policy_name" {
  type        = string
  description = "The name for the AWS CloudWatch Events role policy"
}

variable "cloudwatch_events_rule_name" {
  type        = string
  description = "The name of the AWS CloudWatch Event rule that will trigger the image build pipeline"
}



