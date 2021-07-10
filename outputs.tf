output "codebuild_arn" {
  value = aws_codebuild_project.this.arn
}
output "codebuild_badge_url" {
  value = aws_codebuild_project.this.badge_url
}
output "codebuild_id" {
  value = aws_codebuild_project.this.id
}