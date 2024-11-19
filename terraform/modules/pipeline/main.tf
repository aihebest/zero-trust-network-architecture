# S3 Bucket for artifacts
resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.environment}-${var.project_name}-pipeline-artifacts"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Security group for CodeBuild
resource "aws_security_group" "codebuild" {
  name        = "${var.environment}-codebuild-sg"
  description = "Security group for CodeBuild"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-codebuild-sg"
    }
  )
}