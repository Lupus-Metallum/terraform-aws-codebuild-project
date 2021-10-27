locals {
  service_role_arn = var.service_role_arn != "" ? var.service_role_arn : aws_iam_role.this[0].arn
}

resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_logs == true ? 1 : 0
  name              = "/aws/codebuild/${var.name}"
  retention_in_days = var.cloudwatch_retention_days
  kms_key_id        = var.cloudwatch_kms_key_arn

  tags = merge(
    var.tags,
    {
      Name = "/aws/codebuild/${var.name}",
    },
  )
}

resource "aws_codebuild_project" "this" {
  name                   = var.name
  description            = var.description
  build_timeout          = var.build_timeout
  queued_timeout         = var.queued_timeout
  concurrent_build_limit = var.concurrent_build_limit
  encryption_key         = var.encryption_key
  badge_enabled          = var.badge_enabled

  service_role = local.service_role_arn

  artifacts {
    type = var.artifacts
  }

  cache {
    type  = var.cache_type
    modes = var.cache_mode
  }

  environment {
    compute_type                = var.compute_type
    image                       = var.environment_image
    type                        = var.environment_type
    image_pull_credentials_type = var.image_pull_credentials_type
    privileged_mode             = var.privileged_mode

    dynamic "environment_variable" {
      for_each = var.environment_variables
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source_version = var.source_version
  source {
    type            = var.repo_type
    location        = var.repo_location
    git_clone_depth = var.git_clone_depth
    git_submodules_config {
      fetch_submodules = var.fetch_submodules
    }

    buildspec = var.build_spec
  }

  dynamic "secondary_sources" {
    for_each = var.secondary_sources
    content {
      git_clone_depth     = secondary_sources.value.git_clone_depth
      insecure_ssl        = secondary_sources.value.insecure_ssl
      location            = secondary_sources.value.location
      report_build_status = secondary_sources.value.report_build_status
      source_identifier   = secondary_sources.value.source_identifier
      type                = secondary_sources.value.type

      git_submodules_config {
        fetch_submodules = secondary_sources.value.fetch_submodules
      }
    }
  }

  dynamic "logs_config" {
    for_each = var.enable_logs == true ? [1] : []
    content {
      cloudwatch_logs {
        group_name  = aws_cloudwatch_log_group.this[0].name
        stream_name = var.log_stream_name
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.use_vpc == true ? [1] : []
    content {
      vpc_id             = var.vpc_id
      subnets            = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = var.tags
}

data "aws_iam_policy_document" "this" {
  count = var.service_role_arn == "" ? 1 : 0
  statement {
    effect    = "Allow"
    resources = ["arn:aws:s3:::codepipeline-${data.aws_region.current.name}-*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]
  }
  statement {
    effect    = "Allow"
    resources = ["arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/${var.name}-*"]
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}:*",
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

data "aws_iam_policy_document" "this_cloudwatch" {
  count = (var.enable_logs && var.service_role_arn == "") ? 1 : 0
  statement {
    effect = "Allow"
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}",
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/codebuild/${var.name}:*",
    ]
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
  }
}

# data "aws_iam_policy_document" "this_vpc" {
#   count = (var.use_vpc && var.service_role_arn == "") ? 1 : 0
#   statement {
#     effect   = "Allow"
#     resources = ["*"]
#     actions = [
#       "ec2:CreateNetworkInterface",
#       "ec2:DescribeDhcpOptions",
#       "ec2:DescribeNetworkInterfaces",
#       "ec2:DeleteNetworkInterface",
#       "ec2:DescribeSubnets",
#       "ec2:DescribeSecurityGroups",
#       "ec2:DescribeVpcs"
#     ]
#   }
#   statement {
#     effect   = "Allow"
#     resources = ["arn:aws:ec2:${data.aws_region.current.name}:123456789012:network-interface/*"]
#     actions = [
#       "ec2:CreateNetworkInterfacePermission"
#     ]
#     condition {
#       StringEquals = {
#           "ec2:Subnet" = [

#           ]
#       }
#     }
#   }
# }

data "aws_iam_policy_document" "this_assume" {
  count = var.service_role_arn == "" ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }

    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_role" "this" {
  count              = var.service_role_arn == "" ? 1 : 0
  name               = "codebuild-${var.name}-service-role"
  assume_role_policy = data.aws_iam_policy_document.this_assume[0].json
  path               = "/service-role/"
}

resource "aws_iam_policy" "this" {
  count       = var.service_role_arn == "" ? 1 : 0
  name        = "CodeBuildBasePolicy-${var.name}-${data.aws_region.current.name}"
  policy      = data.aws_iam_policy_document.this[0].json
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"
}

resource "aws_iam_policy" "this_cloudwatch" {
  count       = (var.enable_logs && var.service_role_arn == "") ? 1 : 0
  name        = "CodeBuildCloudWatchLogsPolicy-${var.name}-${data.aws_region.current.name}"
  policy      = data.aws_iam_policy_document.this_cloudwatch[0].json
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild"
}

# resource "aws_iam_policy" "this_vpc" {
#   count = (var.use_vpc && var.service_role_arn == "") ? 1 : 0
#   name  = "CodeBuildCVPCPolicy-${var.name}-${data.aws_region.current.name}"
#   policy = data.aws_iam_policy_document.this_vpc[0].json
#   path = "/service-role/"
#   description = "Policy used in trust relationship with CodeBuild"
# }

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.service_role_arn == "" ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[0].arn
}

resource "aws_iam_role_policy_attachment" "this_cloudwatch" {
  count      = (var.enable_logs && var.service_role_arn == "") ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this_cloudwatch[0].arn
}

resource "aws_iam_role_policy_attachment" "this_AmazonEC2ContainerRegistryFullAccess" {
  count      = (var.add_ecr_write_permissions && var.service_role_arn == "") ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# resource "aws_iam_role_policy_attachment" "this_vpc" {
#   count = (var.use_vpc && var.service_role_arn == "") ? 1 : 0
#   role       = aws_iam_role.this[0].name
#   policy_arn = aws_iam_policy.this_vpc[0].arn
# }

resource "aws_codestarnotifications_notification_rule" "this" {
  for_each       = { for rule in var.notification_rules : rule.notification_name => rule }
  detail_type    = each.value.notification_detail
  event_type_ids = each.value.notification_events

  name     = each.value.notification_name
  resource = aws_codebuild_project.this.arn

  target {
    address = each.value.notification_arn
    type    = each.value.notification_type
  }
}

resource "aws_codebuild_webhook" "this" {
  for_each     = { for webhook in var.webhooks : webhook.branch => webhook }
  project_name = aws_codebuild_project.this.name

  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = join(", ", each.value.events)
      type                    = "EVENT"
    }

    filter {
      type    = "HEAD_REF"
      pattern = each.value.branch
    }
  }
}
