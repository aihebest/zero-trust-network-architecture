output "repository_clone_url_http" {
  description = "Repository clone URL"
  value       = aws_codecommit_repository.infrastructure.clone_url_http
}

output "pipeline_name" {
  description = "Name of the CodePipeline"
  value       = aws_codepipeline.infrastructure.name
}

output "codebuild_project_name" {
  description = "Name of the CodeBuild project"
  value       = aws_codebuild_project.infrastructure.name
}

output "artifact_bucket" {
  description = "S3 bucket for pipeline artifacts"
  value       = aws_s3_bucket.artifacts.bucket
}