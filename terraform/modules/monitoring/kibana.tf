# Kibana configuration with security group based access
resource "aws_elasticsearch_domain_policy" "monitoring" {
  domain_name = aws_elasticsearch_domain.monitoring.domain_name

  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.kibana_role.arn
        }
        Action = "es:*"
        Resource = "${aws_elasticsearch_domain.monitoring.arn}/*"
      }
    ]
  })

  depends_on = [aws_elasticsearch_domain.monitoring]
}

# IAM role for Kibana access
resource "aws_iam_role" "kibana_role" {
  name = "${var.environment}-kibana-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}