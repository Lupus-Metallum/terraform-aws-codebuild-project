variable "name" {
  description = "Name of CodeBuild Project"
  type        = string
}
variable "description" {
  description = "Description of CodeBuild Project"
  type        = string
}
variable "build_timeout" {
  description = "Time in minutes for the build to timeout"
  type        = number
}
variable "queued_timeout" {
  description = "Time in minutes for the queue to timeout"
  type        = number
}

variable "service_role_arn" {
  description = "Time in minutes for the queue to timeout"
  type        = string
  default     = ""
}

variable "artifacts" {
  description = "Should the build create artifacts"
  type        = string
  default     = "NO_ARTIFACTS"
}

variable "concurrent_build_limit" {
  description = "How many concurrent builds should be allowed"
  type        = number
  default     = 1
}

variable "encryption_key" {
  description = "Encryption key to use to encrypt the pipeline"
  type        = string
  default     = ""
}

variable "cache_type" {
  description = "Type of cache to use for builds"
  type        = string
  default     = "NO_CACHE"
}

variable "cache_mode" {
  description = "Type of cache to use for builds"
  type        = list(string)
  default     = []
}

variable "badge_enabled" {
  description = "Should we enable the build badge"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "environment_image" {
  description = "Image to use for builds"
  type        = string
  default     = "aws/codebuild/standard:1.0"
}

variable "privileged_mode" {
  description = "Should we enable privileged mode"
  type        = bool
  default     = false
}

variable "environment_variables" {
  description = "Environment variables to use for build"
  type        = map(string)
  default     = {}
}

variable "repo_location" {
  description = "URL to use for location of repo"
  type        = string
}

variable "repo_type" {
  description = "Type of git repo"
  type        = string
  default     = "GITHUB"
}

variable "source_version" {
  description = "Name of source version"
  type        = string
  default     = "main"
}

variable "git_clone_depth" {
  description = "Depth of git clone"
  type        = number
  default     = 1
}

variable "fetch_submodules" {
  description = "Should we fetch submodules"
  type        = bool
  default     = false
}

variable "build_spec" {
  description = "Yaml for the build, best to provide via file() or template_file datasource"
  type        = string
}

variable "enable_logs" {
  description = "Should we enable cloudwatch logs? Requires a group name and stream name"
  type        = bool
  default     = false
}

variable "cloudwatch_kms_key_arn" {
  type        = string
  default     = ""
  description = "What is the KMS Key ID that we should encrypt logs with"
}

variable "cloudwatch_retention_days" {
  type        = number
  default     = 14
  description = "How many days should we retain logs"
}

variable "log_stream_name" {
  description = "Name of log stream to use for builds, requires enable_logs=true"
  default     = ""
  type        = string
}

variable "use_vpc" {
  description = "Should we build in a vpc? Requires security_group_ids, subnet_ids, and vpc_id"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security_group_ids for the build, requires use_vpc=true"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "List of subnet_ids for the build, requires use_vpc=true"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID of vpc to use for the build, requires use_vpc=true"
  type        = string
  default     = ""
}

variable "secondary_sources" {
  description = "addtional sources to use for the build"
  type        = list(map(string))
  default     = []
}

variable "compute_type" {
  description = "Type of compute to use for the build"
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
}

variable "environment_type" {
  description = "Type of environment to use for the build"
  type        = string
  default     = "LINUX_CONTAINER"
}

variable "image_pull_credentials_type" {
  description = "Type of image pull credentials to use for the build"
  type        = string
  default     = "CODEBUILD"
}

variable "add_ecr_write_permissions" {
  description = "Should add AmazonEC2ContainerRegistryFullAccess Policy to the role?"
  type        = bool
  default     = false
}

variable "notification_rules" {
  description = "Disable or enable notifications"
  type = list(object({
    notification_arn    = string
    notification_type   = string
    notification_name   = string
    notification_detail = string
    notification_events = list(string)
  }))
  default = []
}

variable "webhooks" {
  description = "Should webhooks to the git repo be enabled"
  type = list(object({
    branch = string
    events = list(string)
  }))
  default = []
}
