#!/bin/bash
set -e +x

read -p "migrate local terraform state file to Amazon S3? Press Enter to continue or CTRL+C to abort"
echo "[INFO] copying local state file to s3"
aws s3 cp ./terraform/terraform.tfstate s3://${TF_S3_BUCKET_NAME}/${TF_WORKSPACE_KEY_PREFIX}/${TF_WORKSPACE_NAME}/terraform.tfstate

echo "[INFO] moving local state files to backup folder"
mkdir -v ./tfstatebackup
mv -v ./terraform/terraform.tfstate ./tfstatebackup

if [ -f "./terraform/terraform.tfstate.backup" ]; then
    mv -v ./terraform/terraform.tfstate.backup ./tfstatebackup
else
    echo "[INFO] ./terraform/terraform.tfstate.backup file not found. Skipping"
fi

mv -v ./terraform/.terraform.lock.hcl ./tfstatebackup

echo "[INFO] copying _backend.tf to terraform folder"
cp -v ./temp/_backend.tf ./terraform

echo "[INFO] Replacing Makefile with commands compatible with Amazon S3 and Amazon DynamoDB backend"
cp -vf ./temp/Makefile.s3backend Makefile