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
  cloudwatch_kms_key_arn    = "arn:..."
  cloudwatch_retention_days = 14
  log_stream_name           = "my-stream"
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
<!-- BEGIN_TF_DOCS -->

<img src="https://raw.githubusercontent.com/Lupus-Metallum/brand/master/images/logo.jpg" width="400"/>



## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_webhook.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_webhook) | resource |
| [aws_codestarnotifications_notification_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarnotifications_notification_rule) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this_AmazonEC2ContainerRegistryFullAccess](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.this_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_build_spec"></a> [build\_spec](#input\_build\_spec) | Yaml for the build, best to provide via file() or template\_file datasource | `string` | n/a | yes |
| <a name="input_build_timeout"></a> [build\_timeout](#input\_build\_timeout) | Time in minutes for the build to timeout | `number` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of CodeBuild Project | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of CodeBuild Project | `string` | n/a | yes |
| <a name="input_queued_timeout"></a> [queued\_timeout](#input\_queued\_timeout) | Time in minutes for the queue to timeout | `number` | n/a | yes |
| <a name="input_repo_location"></a> [repo\_location](#input\_repo\_location) | URL to use for location of repo | `string` | n/a | yes |
| <a name="input_add_ecr_write_permissions"></a> [add\_ecr\_write\_permissions](#input\_add\_ecr\_write\_permissions) | Should add AmazonEC2ContainerRegistryFullAccess Policy to the role? | `bool` | `false` | no |
| <a name="input_artifacts"></a> [artifacts](#input\_artifacts) | Should the build create artifacts | `string` | `"NO_ARTIFACTS"` | no |
| <a name="input_badge_enabled"></a> [badge\_enabled](#input\_badge\_enabled) | Should we enable the build badge | `bool` | `true` | no |
| <a name="input_cache_mode"></a> [cache\_mode](#input\_cache\_mode) | Type of cache to use for builds | `list(string)` | `[]` | no |
| <a name="input_cache_type"></a> [cache\_type](#input\_cache\_type) | Type of cache to use for builds | `string` | `"NO_CACHE"` | no |
| <a name="input_cloudwatch_kms_key_arn"></a> [cloudwatch\_kms\_key\_arn](#input\_cloudwatch\_kms\_key\_arn) | What is the KMS Key ID that we should encrypt logs with | `string` | `""` | no |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](#input\_cloudwatch\_retention\_days) | How many days should we retain logs | `number` | `14` | no |
| <a name="input_compute_type"></a> [compute\_type](#input\_compute\_type) | Type of compute to use for the build | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_concurrent_build_limit"></a> [concurrent\_build\_limit](#input\_concurrent\_build\_limit) | How many concurrent builds should be allowed | `number` | `1` | no |
| <a name="input_enable_logs"></a> [enable\_logs](#input\_enable\_logs) | Should we enable cloudwatch logs? Requires a group name and stream name | `bool` | `false` | no |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | Encryption key to use to encrypt the pipeline | `string` | `""` | no |
| <a name="input_environment_image"></a> [environment\_image](#input\_environment\_image) | Image to use for builds | `string` | `"aws/codebuild/standard:1.0"` | no |
| <a name="input_environment_type"></a> [environment\_type](#input\_environment\_type) | Type of environment to use for the build | `string` | `"LINUX_CONTAINER"` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables to use for build | `map(string)` | `{}` | no |
| <a name="input_fetch_submodules"></a> [fetch\_submodules](#input\_fetch\_submodules) | Should we fetch submodules | `bool` | `false` | no |
| <a name="input_git_clone_depth"></a> [git\_clone\_depth](#input\_git\_clone\_depth) | Depth of git clone | `number` | `1` | no |
| <a name="input_image_pull_credentials_type"></a> [image\_pull\_credentials\_type](#input\_image\_pull\_credentials\_type) | Type of image pull credentials to use for the build | `string` | `"CODEBUILD"` | no |
| <a name="input_log_stream_name"></a> [log\_stream\_name](#input\_log\_stream\_name) | Name of log stream to use for builds, requires enable\_logs=true | `string` | `""` | no |
| <a name="input_notification_rules"></a> [notification\_rules](#input\_notification\_rules) | Disable or enable notifications | <pre>list(object({<br>    notification_arn    = string<br>    notification_type   = string<br>    notification_name   = string<br>    notification_detail = string<br>    notification_events = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_privileged_mode"></a> [privileged\_mode](#input\_privileged\_mode) | Should we enable privileged mode | `bool` | `false` | no |
| <a name="input_repo_type"></a> [repo\_type](#input\_repo\_type) | Type of git repo | `string` | `"GITHUB"` | no |
| <a name="input_secondary_sources"></a> [secondary\_sources](#input\_secondary\_sources) | addtional sources to use for the build | `list(map(string))` | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security\_group\_ids for the build, requires use\_vpc=true | `list(string)` | `[]` | no |
| <a name="input_service_role_arn"></a> [service\_role\_arn](#input\_service\_role\_arn) | Time in minutes for the queue to timeout | `string` | `""` | no |
| <a name="input_source_version"></a> [source\_version](#input\_source\_version) | Name of source version | `string` | `"main"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet\_ids for the build, requires use\_vpc=true | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_use_vpc"></a> [use\_vpc](#input\_use\_vpc) | Should we build in a vpc? Requires security\_group\_ids, subnet\_ids, and vpc\_id | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of vpc to use for the build, requires use\_vpc=true | `string` | `""` | no |
| <a name="input_webhooks"></a> [webhooks](#input\_webhooks) | Should webhooks to the git repo be enabled | <pre>list(object({<br>    branch = string<br>    events = list(string)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_codebuild_arn"></a> [codebuild\_arn](#output\_codebuild\_arn) | n/a |
| <a name="output_codebuild_badge_url"></a> [codebuild\_badge\_url](#output\_codebuild\_badge\_url) | n/a |
| <a name="output_codebuild_id"></a> [codebuild\_id](#output\_codebuild\_id) | n/a |
<!-- END_TF_DOCS -->