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

.EXPORT_ALL_VARIABLES:

.PHONY: terraform_fmt terraform_validate clean terraform_prereq_init terraform_prereq_show terraform_prereq_destroy terraform_pipeline_init terraform_pipeline_show terraform_pipeline_destroy terraform_infra_init terraform_infra_show terraform_infra_destroy

all: usage

usage:
	@echo
	@echo === Help: Command Reference ===
	@echo make terraform_fmt               - format the terraform files in the standard style.
	@echo make terraform_validate          - validates the terraform code.
	@echo make terraform_prereq_init       - initialise the terraform prereq project.
	@echo make terraform_prereq_show       - show the prereq resources.
	@echo make terraform_prereq_destroy    - destroy all prereq resources that were deployed
	@echo make terraform_pipline_init      - initialise the terraform pipeline project.
	@echo make terraform_pipeline_show     - show the pipeline resources.
	@echo make terraform_pipeline_destroy  - destroy all pipeline resources that were deployed
	@echo make terraform_infra_init        - initialise the terraform infra project.
	@echo make terraform_infra_show        - show the infra resources.
	@echo make terraform_infra_destroy     - destroy all infra resources that were deployed
	@echo make clean                       - delete all .terraform/* and .terraform.lock.hcl files
	@echo make                             - show this help
	@echo 

terraform_fmt:
	${TF_CLI} -chdir=${TF_FOLDER} fmt -recursive .

terraform_validate:
	${TF_CLI}  -chdir=${TF_FOLDER} validate

clean:
	@echo "[INFO] deleting ${TF_FOLDER}/infra/.terraform/*"
	rm -rvf ${TF_FOLDER}/infra/.terraform
	@echo "[INFO] deleting ${TF_FOLDER}/infra/.terraform.lock.hcl"
	rm -fv ${TF_FOLDER}/infra/.terraform.lock.hcl

	@echo "[INFO] deleting ${TF_FOLDER}/pipeline/.terraform/*"
	rm -rvf ${TF_FOLDER}/pipeline/.terraform
	@echo "[INFO] deleting ${TF_FOLDER}/pipeline/.terraform.lock.hcl"
	rm -fv ${TF_FOLDER}/pipeline/.terraform.lock.hcl

	@echo "[INFO] deleting ${TF_FOLDER}/prereq/.terraform/*"
	rm -rvf ${TF_FOLDER}/prereq/.terraform
	@echo "[INFO] deleting ${TF_FOLDER}/prereq/.terraform.lock.hcl"
	rm -fv ${TF_FOLDER}/prereq/.terraform.lock.hcl

terraform_prereq_init:
	${TF_CLI} -chdir=${TF_FOLDER}/prereq init \
      -backend=true \
      -backend-config="bucket=${TF_S3_BUCKET_NAME}" \
      -backend-config="key=terraform.tfstate" \
      -backend-config="encrypt=true" \
      -backend-config="dynamodb_table=${TF_DYNAMODB_LOCK_TABLE_NAME}" \
      -backend-config="workspace_key_prefix=${TF_WORKSPACE_KEY_PREFIX}_prereq"

terraform_pipeline_init:
	${TF_CLI} -chdir=${TF_FOLDER}/pipeline init \
      -backend=true \
      -backend-config="bucket=${TF_S3_BUCKET_NAME}" \
      -backend-config="key=terraform.tfstate" \
      -backend-config="encrypt=true" \
      -backend-config="dynamodb_table=${TF_DYNAMODB_LOCK_TABLE_NAME}" \
      -backend-config="workspace_key_prefix=${TF_WORKSPACE_KEY_PREFIX}"

terraform_infra_init:
	${TF_CLI} -chdir=${TF_FOLDER}/infra init \
      -backend=true \
      -backend-config="bucket=${TF_S3_BUCKET_NAME}" \
      -backend-config="key=terraform.tfstate" \
      -backend-config="encrypt=true" \
      -backend-config="dynamodb_table=${TF_DYNAMODB_LOCK_TABLE_NAME}" \
      -backend-config="workspace_key_prefix=${TF_WORKSPACE_KEY_PREFIX}_infra"

terraform_prereq_show:
	${TF_CLI} -chdir=${TF_FOLDER}/prereq workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/prereq state list

terraform_pipeline_show:
	${TF_CLI} -chdir=${TF_FOLDER}/pipeline workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/pipeline state list

terraform_infra_show:
	${TF_CLI} -chdir=${TF_FOLDER}/infra workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/infra state list

terraform_prereq_destroy:
	${TF_CLI} -chdir=${TF_FOLDER}/prereq workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/prereq destroy

terraform_pipeline_destroy:
	${TF_CLI} -chdir=${TF_FOLDER}/pipeline workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/pipeline destroy

terraform_infra_destroy:
	${TF_CLI} -chdir=${TF_FOLDER}/infra workspace select ${TF_WORKSPACE_NAME} ; \
	${TF_CLI} -chdir=${TF_FOLDER}/infra destroy