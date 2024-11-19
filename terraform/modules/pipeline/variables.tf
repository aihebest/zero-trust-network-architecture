variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where CodeBuild will run"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for CodeBuild"
  type        = list(string)
}

variable "repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string
  default     = "ztna-infrastructure"
}

variable "repository_branch" {
  description = "Repository branch to track"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}