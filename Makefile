# define global variables
ENV ?= <myenv>
PROJECT_NAME := <myprojectname>

TF_FOLDER := ./terraform

# variables for storing the state file in s3 backend
TF_S3_BUCKET_NAME := <mys3bucketname>

# store the terraform state files inside a root folder in the s3 bucket
TF_S3_BUCKET_KEY_PREFIX := terraform

TF_WORKSPACE_KEY_PREFIX := ${TF_S3_BUCKET_KEY_PREFIX}/${PROJECT_NAME}
TF_WORKSPACE_NAME := ${ENV}
TF_DYNAMODB_LOCK_TABLE_NAME := ${PROJECT_NAME}-${ENV}-terraform-lock

TF_CLI := docker-compose run --rm terraform_container

TF_PLAN_FILENAME := ${PROJECT_NAME}_plan.tfplan

# define terraform variables
TF_VAR_env = ${ENV}
TF_VAR_project = ${PROJECT_NAME}

TF_VAR_owner_email = <myemailaddress>

TF_VAR_s3_bucket_name = ${TF_S3_BUCKET_NAME}
TF_VAR_s3_bucket_key_prefix = ${TF_S3_BUCKET_KEY_PREFIX}

TF_VAR_dynamodb_lock_table_name = ${TF_DYNAMODB_LOCK_TABLE_NAME}

TF_VAR_codepipeline_artifacts_s3_bucket_name = ${TF_S3_BUCKET_NAME}
TF_VAR_codepipeline_artifacts_s3_bucket_kms_key_alias = ${TF_S3_BUCKET_NAME}-${ENV}

TF_VAR_codepipeline_pipeline_name = ${PROJECT_NAME}_${ENV}_pipeline
TF_VAR_codepipeline_role_name = ${PROJECT_NAME}_${ENV}_codepipeline_role
TF_VAR_codepipeline_role_policy_name = ${TFVAR_codepipeline_role_name}_policy

TF_VAR_codecommit_infra_repo_name = ${PROJECT_NAME}_${ENV}_infra
TF_VAR_codecommit_infra_repo_default_branch_name = main
TF_VAR_codecommit_app_repo_name = ${PROJECT_NAME}_${ENV}_app
TF_VAR_codecommit_app_repo_default_branch_name = main

TF_VAR_codebuild_project_name_prefix = ${PROJECT_NAME}_${ENV}
TF_VAR_codebuild_service_role_name = ${PROJECT_NAME}-${ENV}-codebuild-service-role
TF_VAR_codebuild_cloudwatch_logs_group_name = ${PROJECT_NAME}_${ENV}_codebuildloggroup
TF_VAR_codebuild_cloudwatch_logs_stream_name = ${PROJECT_NAME}_${ENV}_codebuildlogstream

TF_VAR_cloudwatch_events_rule_name = ${PROJECT_NAME}_${ENV}_pipeline_trigger
TF_VAR_cloudwatch_events_role_name = ${PROJECT_NAME}_${ENV}_cloudwatch_events_role
TF_VAR_cloudwatch_events_role_policy_name = ${TFVAR_cloudwatch_events_role_name}_policy

.EXPORT_ALL_VARIABLES:

.PHONY: terraform_fmt terraform_init terraform_plan terraform_apply terraform_destroy clean

all: usage

usage:
	@echo
	@echo === Help: Command Reference ===
	@echo make terraform_fmt      - format the terraform files in the standard style.
	@echo make terraform_validate - validates the terraform code.
	@echo make terraform_init     - initialise the terraform project.
	@echo make terraform_plan     - create a plan for the changes that will be deployed.
	@echo make terraform_apply    - apply the changes from the plan stage
	@echo make terraform_destroy  - destroy all that was deployed
	@echo make clean              - delete all terraform provider and plan files.
	@echo make - show this help
	@echo 

terraform_fmt:
	${TF_CLI} -chdir=${TF_FOLDER} fmt -recursive .	

terraform_validate:
	${TF_CLI}  -chdir=${TF_FOLDER} validate
		
terraform_init:
	${TF_CLI} -chdir=${TF_FOLDER} init \
      -backend=true \
      -backend-config="bucket=${TF_S3_BUCKET_NAME}" \
      -backend-config="key=terraform.tfstate" \
      -backend-config="encrypt=true" \
      -backend-config="dynamodb_table=${TF_DYNAMODB_LOCK_TABLE_NAME}" \
      -backend-config="workspace_key_prefix=${TF_WORKSPACE_KEY_PREFIX}"

terraform_plan:
	${TF_CLI} -chdir=${TF_FOLDER} workspace select ${TF_WORKSPACE_NAME} || ${TF_CLI} -chdir=${TF_FOLDER} workspace new ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER} plan -out=${TF_PLAN_FILENAME} -detailed-exitcode ; \
	echo $$? > /tmp/tfplan.result

terraform_apply:
	${TF_CLI} -chdir=${TF_FOLDER} workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER} apply ${TF_PLAN_FILENAME}

terraform_destroy:
	${TF_CLI} -chdir=${TF_FOLDER} workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER} destroy

clean:
	cd ${TF_FOLDER} && rm -rf .terraform && rm -f ${TF_PLAN_FILENAME}
