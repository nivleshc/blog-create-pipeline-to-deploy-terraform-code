# define global variables
ENV ?= <myenv>
PROJECT_NAME_PREFIX := <myprojectname>
PROJECT_NAME := ${PROJECT_NAME_PREFIX}_prereq

TF_FOLDER := ./terraform

# variables for storing the state file in s3 backend
TF_S3_BUCKET_NAME := <mys3bucketname>
# store the terraform state files inside a root folder in the s3 bucket
TF_S3_BUCKET_KEY_PREFIX := terraform
TF_WORKSPACE_KEY_PREFIX := ${TF_S3_BUCKET_KEY_PREFIX}/${PROJECT_NAME}
TF_DYNAMODB_LOCK_TABLE_NAME := ${PROJECT_NAME_PREFIX}-${ENV}-terraform-lock
TF_WORKSPACE_NAME := ${ENV}

TF_CLI := docker-compose run --rm terraform_container
TF_PLAN_FILENAME := ${PROJECT_NAME}_plan.tfplan

# define terraform variables
TF_VAR_s3_bucket_name = ${TF_S3_BUCKET_NAME}
TF_VAR_dynamodb_lock_table_name = ${TF_DYNAMODB_LOCK_TABLE_NAME}
TF_VAR_env = ${ENV}

.EXPORT_ALL_VARIABLES:

.PHONY: terraform_fmt terraform_init terraform_plan terraform_apply terraform_destroy clean migrate_terraform_statefile

all: usage

usage:
	@echo
	@echo === Help: Command Reference ===
	@echo make terraform_fmt      - format the terraform files in the standard style.
	@echo make terraform_validate - validates the terraform code.
	@echo make terraform_init     - initialise the terraform project.
	@echo make terraform_plan     - create a plan for the changes that will be deployed.
	@echo make terraform_apply    - apply the changes from the plan stage.
	@echo make terraform_destroy  - destroy all that was deployed.
	@echo make clean              - delete all terraform provider and plan files.
	@echo make - show this help
	@echo 

terraform_fmt:
	${TF_CLI}  -chdir=${TF_FOLDER} fmt -recursive .	

terraform_validate:
	${TF_CLI}  -chdir=${TF_FOLDER} validate
		
terraform_init:
	${TF_CLI}  -chdir=${TF_FOLDER} init

terraform_plan:
	${TF_CLI}  -chdir=${TF_FOLDER} plan -out=${TF_PLAN_FILENAME} -detailed-exitcode ; echo $$? >tfplan.result

terraform_apply:
	${TF_CLI} -chdir=${TF_FOLDER} apply ${TF_PLAN_FILENAME}

migrate_terraform_statefile:
	bash ./scripts/migrate_terraform_statefile.sh

clean:
	cd ${TF_FOLDER} && rm -rf .terraform && rm -f ${TF_PLAN_FILENAME}
