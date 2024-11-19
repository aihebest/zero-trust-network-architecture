# AWS Config
resource "aws_config_configuration_recorder" "main" {
  name     = "${var.environment}-config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
}

# AWS Config Rules
resource "aws_config_config_rule" "vpc_flow_logs_enabled" {
  name = "${var.environment}-vpc-flow-logs-enabled"

  source {
    owner             = "AWS"
    source_identifier = "VPC_FLOW_LOGS_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_config_rule" "encrypted_volumes" {
  name = "${var.environment}-encrypted-volumes"

  source {
    owner             = "AWS"
    source_identifier = "ENCRYPTED_VOLUMES"
  }

  depends_on = [aws_config_configuration_recorder.main]
}

# Systems Manager
resource "aws_ssm_document" "session_manager_prefs" {
  name            = "${var.environment}-session-manager-prefs"
  document_type   = "Session"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "1.0"
    description   = "Session Manager Preferences"
    sessionType   = "Standard_Stream"
    inputs = {
      cloudWatchLogGroupName      = aws_cloudwatch_log_group.session_manager.name
      cloudWatchEncryptionEnabled = true
      cloudWatchStreamingEnabled  = true
    }
  })
}

resource "aws_cloudwatch_log_group" "session_manager" {
  name              = "/aws/session-manager/${var.environment}"
  retention_in_days = 30
  
  tags = var.tags
}

resource "aws_config_delivery_channel" "main" {
  name           = "${var.environment}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config.id

  depends_on = [aws_config_configuration_recorder.main]
}

data "aws_guardduty_detector" "existing" {
  count = var.enable_guardduty ? 1 : 0
}

resource "aws_guardduty_detector" "main" {
  count = 0  # Disable creation since detector exists

  enable = true
  finding_publishing_frequency = "ONE_HOUR"

  tags = var.tags
}