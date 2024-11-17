provider "aws" {
  region = "us-west-2"  # Change as needed
}

terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    # Will be configured later
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

module "vpc" {
  source = "../../modules/vpc"
  
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "iam" {
  source = "../../modules/iam"
  
  environment = "dev"
}
