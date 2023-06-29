# Use AWS CodePipeline, AWS CodeCommit, AWS CodeBuild, Amazon Simple Storage Service, Amazon DynamoDB and Docker to create a serverless pipeline to deploy terraform code

This repository contains code to create a serverless pipeline using AWS CodePipeline, AWS CodeCommit, AWS CodeBuild, Amazon Simple Storage Services (S3), AWS Key Management Service (KMS) Customer Managed Key (CMK), Amazon DynamoDB, Amazon EventBridge and Docker that will be used to deploy terraform code.

The code is written using Terraform.

A Terraform container (specified in docker-compose.yaml) is used to run the Terraform code.

## High Level Architecture
The diagram below shows the high level architecture for the solution.

![High Level Architector for Serverless Pipeline To Deploy Terraform Projects](images/high%20level%20architecture.png)

## Requirements
Before continuing, ensure that the following are installed (and configured)on your local computer (or where you will be running this solution from).
- AWS CLI tools
- AWS Profile has been configured to connect to your AWS Account
- Git CLI
- Make
- Docker

## Implementation
Clone the repository using the following command

``
    git clone https://github.com/nivleshc/blog-create-pipeline-to-deploy-terraform-code.git
``

### Pre-requisites
Run the following commands to deploy the prerequisites for this solution.
1. Open the file called *Makefile* inside **_prerequisites** folder and make the following changes.

    - ENV - change \<myenv\> with the name for the environment of your choice, for example dev

    - PROJECT_NAME_PREFIX - change \<myprojectname\> with a name for this project.

    - TF_S3_BUCKET_NAME - change \<mybucketname\> with the name to use to create an Amazon S3 bucket. This will be used to store the Terraform state files and the AWS CodePipeline artifacts. Amazon S3 bucket names need to be globally unique, to ensure your name is available, add some unique characters to it.

2. Do the same changes that were done in step 2 above to the following files as well 
    - _prerequisites\temp\Makefile.localbackend
    - _prerequisites\temp\Makefile.s3backend

3. Open _prerequisites\terraform\_provider.tf and change the following values under **default_tags**. These will be used to tag all resources that will be created. You can add additional tags in this section as well.
    - \<myenv\> - replace this with the environment name used in Makefile
    - \<myname\> - replace this with your name.

4. Open a command line (Terminal on MacOS) and change to **_prerequisites** folder. Run the following command, to initialise the Terraform Project.

    ``
        make terraform_init
    ``

5. Run the following command to show the changes that will be deployed into your AWS Account.
``
    make terraform_plan
``

6. Once satisfied with the changes, run the following command to deploy the changes into your AWS Account.

    ``
        make terraform_apply
    ``

7. Currently the Terraform state file is stored locally, run the following command to move it to the Amazon S3 bucket. This will also replace the Makefile, to ensure it uses the new backend.
``
    make migrate_terraform_statefile
``

8. After the above command succeeds, initialise the Terraform project again, using the following command.
``
    make terraform_init
``

9. Confirm that there are no changes required by running the following command.
``
    make terraform_plan
``

### Serverless Pipeline
After the prerequisites have been deployed, run the following command to deploy the Serverless Pipeline.

1. Open *Makefile* from the root of the Github folder and do the following changes.
    - ENV - change "\<myenv\>" to the same value that was used in the prerequisites.

    - PROJECT_NAME - change \<myprojectname\> to the value that was used for **PROJECT_NAME_PREFIX** in the prerequisites.

    - TF_S3_BUCKET_NAME - change \<mys3bucketname\> to the Amazon S3 bucket name that was used for prerequisites.

    - TF_VAR_infra_approver_email - change \<infraapproveremailaddress\> to the infrastructure approver's email address. This email address will be used to approve/reject infrastructure changes that are deployed to the Serverless infrastructure pipeline.

    - TF_VAR_app_approver_email - change \<appapproveremailaddress\> to the application approver's email address. This email address will be used to approve/reject application changes that are deployed to the Serverless application pipeline.

2. Update the values under **default_tags** in file terraform/_provider.tf to match those that were used for the prerequisites.

3. Use the command line, from within the root of the cloned GitHub repo folder to run the following command. This initialises the Terraform project.

    ``
        make terraform_init
    ``
4. Run the following command to show the changes that will be performed to your AWS Account.
``
    make terraform_plan
``
5. Once satisfied, run the following command to deploy the changes into your AWS Account.
``
    make terraform_apply
``
6. Amazon SNS will send an email to the owner email address that was provided. Ensure you click on the link, to confirm otherwise, you won't receive any emails when the Servereless pipeline runs.

Full details for this solution can be found at below locations
- https://nivleshc.wordpress.com/2023/03/28/use-aws-codepipeline-aws-codecommit-aws-codebuild-amazon-simple-storage-service-amazon-dynamodb-and-docker-to-create-a-pipeline-to-deploy-terraform-code/

- https://nivleshc.wordpress.com/2023/06/29/add-an-application-pipeline-to-the-serverless-terraform-pipeline/