# terraform-aws-codebuild-project

This configures everything except Auth to source control.

## Example

``` Terraform
module "codebuild_example" {
  source                    = "Lupus-Metallum/codebuild-project/aws"
  version                   = "1.0.0
  name                      = "Example"
  description               = "This is an example"
  build_timeout             = 5
  queued_timeout            = 5
  concurrent_build_limit    = 1
  encryption_key            = "arn:aws:kms:us-east-1:00000:alias/aws/s3"
  environment_image         = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
  add_ecr_write_permissions = true
  compute_type              = "BUILD_GENERAL1_MEDIUM"
  environment_type          = "LINUX_CONTAINER"
  privileged_mode           = true
  repo_location             = "https://github.com/MyOrg/example.git"
  source_version            = "dev"
  build_spec                = file("./src/buildspec.yml")
  enable_logs               = true
  log_group_name            = "CloudBuild-Example"
  log_stream_name           = "CodeBuild"
  environment_variables = {
    "IMAGE_REPO_NAME"    = "example"
    "AWS_DEFAULT_REGION" = data.aws_region.current.name
    "AWS_ACCOUNT_ID"     = data.aws_caller_identity.current.account_id
    "IMAGE_TAG"          = "latest"
  }
  secondary_sources = [
    {
      git_clone_depth     = 1
      insecure_ssl        = false
      location            = "https://github.com/MyOrg/example2.git"
      report_build_status = false
      source_identifier   = "dev"
      type                = "GITHUB"
      fetch_submodules    = false
    },
    {
      git_clone_depth     = 1
      insecure_ssl        = false
      location            = "https://github.com/MyOrg/example3.git"
      report_build_status = false
      source_identifier   = "example3"
      type                = "GITHUB"
      fetch_submodules    = false
    },
  ]
  notification_rules = [
    {
      notification_arn    = "arn:aws:chatbot::0000000:chat-configuration/slack-channel/Codebuild-Notifications",
      notification_type   = "AWSChatbotSlack",
      notification_name   = "Codebuild-Default",
      notification_detail = "FULL",
      notification_events = [
        "codebuild-project-build-phase-failure",
        "codebuild-project-build-state-failed",
        "codebuild-project-build-state-in-progress",
        "codebuild-project-build-state-stopped",
        "codebuild-project-build-state-succeeded",
      ]
    }
  ]
  webhooks = [
    {
      branch = "dev"
      events = ["PUSH", "PULL_REQUEST_MERGED"]
    }
  ]
}
```