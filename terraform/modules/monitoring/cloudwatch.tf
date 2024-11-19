# Add AWS caller identity data source
data "aws_caller_identity" "current" {}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc-flow-logs/${var.environment}-monitoring"
  retention_in_days = 30
  tags              = var.tags
}

# CloudWatch Metrics and Alarms
resource "aws_cloudwatch_metric_alarm" "es_cluster_status" {
  alarm_name          = "${var.environment}-es-cluster-status"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "FreeStorageSpace"
  namespace          = "AWS/ES"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors elasticsearch cluster status"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DomainName = aws_elasticsearch_domain.monitoring.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

# VPC Flow Logs Metric Alarm
resource "aws_cloudwatch_metric_alarm" "vpc_flow_logs_error" {
  alarm_name          = "${var.environment}-vpc-flow-logs-error"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ErrorCount"
  namespace          = "AWS/Logs"
  period             = "300"
  statistic          = "Sum"
  threshold          = "0"
  alarm_description  = "This metric monitors VPC Flow Logs errors"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.vpc_flow_logs.name
  }
}

# Elasticsearch Cluster Health Alarm
resource "aws_cloudwatch_metric_alarm" "es_cluster_health" {
  alarm_name          = "${var.environment}-es-cluster-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "ClusterStatus.red"
  namespace          = "AWS/ES"
  period             = "300"
  statistic          = "Maximum"
  threshold          = "0"
  alarm_description  = "This metric monitors elasticsearch cluster health"
  alarm_actions      = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    DomainName = aws_elasticsearch_domain.monitoring.domain_name
    ClientId   = data.aws_caller_identity.current.account_id
  }
}

# SNS Topic for monitoring alerts
resource "aws_sns_topic" "monitoring_alerts" {
  name = "${var.environment}-monitoring-alerts"
  tags = var.tags
}