# CodeCommit Repository
resource "aws_codecommit_repository" "infrastructure" {
  repository_name = var.repository_name
  description     = "Infrastructure as Code repository for ${var.project_name}"
  tags           = var.tags
}

# CodePipeline
resource "aws_codepipeline" "infrastructure" {
  name     = "${var.environment}-${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.infrastructure.repository_name
        BranchName     = var.repository_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.infrastructure.name
      }
    }
  }
}