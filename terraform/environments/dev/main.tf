terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket = "ztna-terraform-state-2024"
    key    = "dev/terraform.tfstate"
    region = "us-west-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

locals {
  environment  = "dev"
  project_name = "ztna"
  tags = {
    Project     = "ZTNA"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"
  
  environment = local.environment
  vpc_cidr    = "10.0.0.0/16"
  
  tags = local.tags
}

module "security" {
  source = "../../modules/security"

  environment        = local.environment
  vpc_id            = module.vpc.vpc_id
  vpc_cidr          = "10.0.0.0/16"
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  tags = local.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  environment        = local.environment
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  tags = local.tags
}

# ... (previous modules remain unchanged)

module "pipeline" {
  source = "../../modules/pipeline"

  environment        = local.environment
  project_name       = local.project_name
  vpc_id            = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  repository_name    = "${local.environment}-${local.project_name}-repo"
  repository_branch  = "main"
  tags              = local.tags
}