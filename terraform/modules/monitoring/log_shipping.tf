# Kinesis Stream for log aggregation
resource "aws_kinesis_stream" "log_stream" {
  name             = "${var.environment}-flow-logs-stream"
  shard_count      = 1
  retention_period = 24

  tags = var.tags
}

# Create Lambda function code file
resource "local_file" "lambda_function" {
  filename = "${path.module}/files/log_shipper.js"
  content  = <<EOF
exports.handler = async (event) => {
    console.log('Received event:', JSON.stringify(event, null, 2));
    return {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
};
EOF
}

# Create ZIP file for Lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/files/log_shipper.zip"
  source {
    content  = local_file.lambda_function.content
    filename = "log_shipper.js"
  }
}

# Lambda function for log shipping
resource "aws_lambda_function" "log_shipper" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "${var.environment}-log-shipper"
  role            = aws_iam_role.lambda_role.arn
  handler         = "log_shipper.handler"
  runtime         = "nodejs18.x"
  timeout         = 300

  environment {
    variables = {
      ES_ENDPOINT = aws_elasticsearch_domain.monitoring.endpoint
      ES_INDEX    = "vpc-flow-logs"
    }
  }

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = var.tags

  depends_on = [data.archive_file.lambda_zip]
}

# Lambda security group
resource "aws_security_group" "lambda" {
  name        = "${var.environment}-lambda-log-shipper-sg"
  description = "Security group for Lambda log shipper"
  vpc_id      = var.vpc_id

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.es.id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-lambda-log-shipper-sg"
    }
  )
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.environment}-log-shipper-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda VPC execution role
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda Kinesis execution role
resource "aws_iam_role_policy" "lambda_kinesis" {
  name = "${var.environment}-lambda-kinesis-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards"
        ]
        Resource = aws_kinesis_stream.log_stream.arn
      }
    ]
  })
}