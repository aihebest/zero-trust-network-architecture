variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ELK stack will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ELK deployment"
  type        = list(string)
}

variable "domain_name" {
  description = "Name of the Elasticsearch domain"
  type        = string
  default     = "ztna-logs"
}

variable "elasticsearch_version" {
  description = "Version of Elasticsearch to deploy"
  type        = string
  default     = "7.10"
}

variable "instance_type" {
  description = "Instance type for Elasticsearch nodes"
  type        = string
  default     = "t3.small.elasticsearch"
}

variable "instance_count" {
  description = "Number of Elasticsearch nodes"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}