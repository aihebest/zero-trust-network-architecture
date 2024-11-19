# Create Elasticsearch domain
resource "aws_elasticsearch_domain" "monitoring" {
  domain_name           = "${var.environment}-${var.domain_name}"
  elasticsearch_version = var.elasticsearch_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = true

    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  vpc_options {
    subnet_ids         = slice(var.private_subnet_ids, 0, 2)
    security_group_ids = [aws_security_group.es.id]
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 20
  }

  encrypt_at_rest {
    enabled = true
  }

  node_to_node_encryption {
    enabled = true
  }

    domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = random_password.es_master.result
    }
  }

  tags = var.tags
}

# Generate random password for Elasticsearch master user
resource "random_password" "es_master" {
  length  = 16
  special = true
}

# Security group for Elasticsearch
resource "aws_security_group" "es" {
  name        = "${var.environment}-elasticsearch-sg"
  description = "Security group for Elasticsearch domain"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.logstash.id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-elasticsearch-sg"
    }
  )
}

# Security group for Logstash
resource "aws_security_group" "logstash" {
  name        = "${var.environment}-logstash-sg"
  description = "Security group for Logstash instances"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-logstash-sg"
    }
  )
}