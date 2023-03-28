data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_s3_bucket" "codepipeline_artifacts_s3_bucket" {
  bucket = var.codepipeline_artifacts_s3_bucket_name
}

resource "aws_codecommit_repository" "infra_repo" {
  repository_name = var.codecommit_infra_repo_name
  description     = "The AWS CodeCommit repository where the infra code will be stored."
  default_branch  = var.codecommit_infra_repo_default_branch_name
}

# create a KMS customer managed key that will be used to encrypt the codepipeline artifacts
resource "aws_kms_key" "codepipeline_kms_key" {
  description = "KMS key used by ${var.project}-${var.env} CodePipeline pipeline"
}

# create an alias for the customer managed KMS key
resource "aws_kms_alias" "codepipeline_kms_key_alias" {
  name          = "alias/${var.project}-${var.env}"
  target_key_id = aws_kms_key.codepipeline_kms_key.id
}

resource "aws_codebuild_project" "infra_plan_project" {
  name                   = "${var.codebuild_project_name_prefix}_plan"
  description            = "AWS CodeBuild Project to display the proposed infrastructure changes"
  build_timeout          = "5"
  concurrent_build_limit = 1
  service_role           = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.codebuild_cloudwatch_logs_group_name
      stream_name = var.codebuild_cloudwatch_logs_stream_name
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.infra_repo.clone_url_http
    git_clone_depth = 1
    buildspec       = "buildspec_infra_plan.yml"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_codebuild_project" "infra_apply_project" {
  name                   = "${var.codebuild_project_name_prefix}_apply"
  description            = "AWS CodeBuild Project to apply the proposed infrastructure changes"
  build_timeout          = "60"
  concurrent_build_limit = 1
  service_role           = aws_iam_role.codebuild_service_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.codebuild_cloudwatch_logs_group_name
      stream_name = var.codebuild_cloudwatch_logs_stream_name
    }
  }

  source {
    type            = "CODECOMMIT"
    location        = aws_codecommit_repository.infra_repo.clone_url_http
    git_clone_depth = 1
    buildspec       = "buildspec_infra_apply.yml"

    git_submodules_config {
      fetch_submodules = true
    }
  }

  tags = {
    Environment = var.env
  }
}

resource "aws_sns_topic" "pipeline_approval_requests" {
  name = "${var.project}-${var.env}_pipeline_approval_requests"
}

resource "aws_sns_topic_subscription" "owner_subscription" {
  topic_arn = aws_sns_topic.pipeline_approval_requests.arn
  protocol  = "email"
  endpoint  = var.owner_email
}

resource "aws_codepipeline" "pipeline" {
  name     = var.codepipeline_pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = data.aws_s3_bucket.codepipeline_artifacts_s3_bucket.id
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.codepipeline_kms_key.id
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]
      namespace        = "SourceVariables"
      configuration = {
        RepositoryName       = aws_codecommit_repository.infra_repo.id
        BranchName           = "main"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "INFRA_TF_PLAN"

    action {
      name             = "INFRA_TF_PLAN_ACTION"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["infra_tf_plan_output"]
      namespace        = "InfraTFPlanVariables"
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infra_plan_project.name
      }
    }
  }

  stage {
    name = "INFRA_TF_CHANGE_APPROVAL"

    action {
      name             = "ApprovalAction"
      category         = "Approval"
      owner            = "AWS"
      version          = "1"
      provider         = "Manual"
      input_artifacts  = []
      output_artifacts = []

      configuration = {
        NotificationArn = aws_sns_topic.pipeline_approval_requests.arn
        CustomData      = "Pipeline approval request for 'CommitId:#{SourceVariables.CommitId}  #{SourceVariables.CommitMessage}'  Terraform Plan ExitCode:#{InfraTFPlanVariables.TERRAFORM_PLAN_STATUS}"
      }

      run_order = 1
    }
  }

  stage {
    name = "INFRA_TF_APPLY"

    action {
      name             = "INFRA_TF_APPLY_ACTION"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["infra_tf_plan_output"]
      output_artifacts = ["infra_tf_apply_output"]
      namespace        = "InfraTFApplyVariables"
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infra_apply_project.name
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "trigger_pipeline" {
  name        = var.cloudwatch_events_rule_name
  description = "Trigger the CodePipeline pipline"

  event_pattern = <<PATTERN
{
  "source": [ 
    "aws.codecommit"
  ],
  "detail-type": [
    "CodeCommit Repository State Change"
  ],
  "resources": [ 
    "${aws_codecommit_repository.infra_repo.arn}"
  ],
  "detail": {
    "event": [
      "referenceCreated",
      "referenceUpdated"
    ],
    "referenceType": [
        "branch"
    ],
    "referenceName": [
      "main"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "pipeline" {
  target_id = "${var.codepipeline_pipeline_name}_target"
  rule      = aws_cloudwatch_event_rule.trigger_pipeline.id
  arn       = aws_codepipeline.pipeline.arn

  role_arn = aws_iam_role.cloudwatch_events_role.arn
}