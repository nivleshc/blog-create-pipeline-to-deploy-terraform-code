terraform {
  required_version = "~> 1.4.2"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket               = var.s3_bucket_name
    key                  = var.s3_bucket_key
    region               = var.region
    encrypt              = true
    dynamodb_table       = var.dynamodb_lock_table_name
    workspace_key_prefix = "${var.s3_bucket_key_prefix}/${var.project_name}_infra"
  }

  workspace = var.env
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = data.terraform_remote_state.infra.outputs.eks_cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.eks_endpoint
  cluster_ca_certificate = base64decode((data.terraform_remote_state.infra.outputs.eks_certificate_authority))
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
}