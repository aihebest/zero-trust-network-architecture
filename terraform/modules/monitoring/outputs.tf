output "elasticsearch_endpoint" {
  description = "Endpoint for the Elasticsearch domain"
  value       = aws_elasticsearch_domain.monitoring.endpoint
}

output "kibana_endpoint" {
  description = "Endpoint for the Kibana dashboard"
  value       = aws_elasticsearch_domain.monitoring.kibana_endpoint
}

output "kinesis_stream_name" {
  description = "Name of the Kinesis stream for log shipping"
  value       = aws_kinesis_stream.log_stream.name
}

output "lambda_function_name" {
  description = "Name of the log shipper Lambda function"
  value       = aws_lambda_function.log_shipper.function_name
}

output "es_master_password" {
  description = "Master password for Elasticsearch"
  value       = random_password.es_master.result
  sensitive   = true
}