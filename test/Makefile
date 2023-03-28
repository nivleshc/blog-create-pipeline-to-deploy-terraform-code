TF_CLI := docker-compose run --rm terraform_container

PROJECT_NAME := test
TF_FOLDER := /terraform
TF_PLAN_FILENAME := ${PROJECT_NAME}_plan.tfplan

.EXPORT_ALL_VARIABLES:

.PHONY: terraform_fmt terraform_init terraform_plan terraform_apply terraform_destroy clean

all: usage

terraform_fmt:
	${TF_CLI} -chdir=${TF_FOLDER} fmt -recursive .	
	
terraform_init:
	${TF_CLI} -chdir=${TF_FOLDER} init

terraform_plan:
	${TF_CLI} -chdir=${TF_FOLDER} plan -out=${TF_PLAN_FILENAME} -detailed-exitcode ; \
	echo $$? > /tmp/tfplan.result

terraform_apply:
	${TF_CLI} -chdir=${TF_FOLDER} apply ${TF_PLAN_FILENAME}

terraform_destroy:
	${TF_CLI} -chdir=${TF_FOLDER} destroy

clean:
	cd .${TF_FOLDER} && rm -rf .terraform && rm -f ${TF_PLAN_FILENAME} && rm -f .terraform.lock.hcl terraform.tfstate