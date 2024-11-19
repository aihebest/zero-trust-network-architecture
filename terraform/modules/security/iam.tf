# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "${var.environment}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# AWS Config IAM Policy
resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# Additional policy for S3 bucket access
resource "aws_iam_role_policy" "config_policy" {
  name = "${var.environment}-config-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          "${aws_s3_bucket.config.arn}",
          "${aws_s3_bucket.config.arn}/*"
        ]
      }
    ]
  })
}

# S3 bucket for AWS Config
resource "aws_s3_bucket" "config" {
  bucket = "${var.environment}-config-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = var.tags
}

# Add data source for AWS account ID
data "aws_caller_identity" "current" {}