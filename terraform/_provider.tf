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

  default_tags {
    tags = {
      Environment = "<myenv>"
      Owner       = "<myname>"
    }
  }
}