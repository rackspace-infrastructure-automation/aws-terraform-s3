/**
 * # aws-terraform-s3
 *
 * This module builds a s3 bucket with varying options.
 * It will not do s3 origin, which is in another module.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "s3_basic" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"
 *
 *   bucket_logging    = false
 *   environment       = "Development"
 *   name              = "${random_string.s3_rstring.result}-example-s3-bucket"
 *   versioning        = true
 *   lifecycle_enabled = true
 *   lifecycle_rule = [
 *     {
 *       id                                     = "Default MPU Cleanup Rule."
 *       enabled                                = true
 *       abort_incomplete_multipart_upload_days = 7
 *     }
 *   ]
 *
 *   tags = {
 *     RightSaid = "Fred"
 *     LeftSaid  = "George"
 *   }
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should be
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Module variables
 *
 * The following module variables were updated to better meet current Rackspace style guides:
 *
 * - `bucket_name` -> `name`
 * - `kms_master_key_id` -> `kms_key_id`
 * - `bucket_tags` -> `tags`
 *
 */

data "aws_canonical_user_id" "this" {}

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {

  ##############################################################
  # Bucket local variables
  ##############################################################

  acl_list = ["authenticated-read", "aws-exec-read", "log-delivery-write", "private", "public-read", "public-read-write"]

  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  grants               = try(jsondecode(var.grant), var.grant)
  cors_rules           = try(jsondecode(var.cors_rule), var.cors_rule)
  lifecycle_rules      = try(jsondecode(var.lifecycle_rule), var.lifecycle_rule)
  intelligent_tiering  = try(jsondecode(var.intelligent_tiering), var.intelligent_tiering)
  metric_configuration = try(jsondecode(var.metric_configuration), var.metric_configuration)

}

resource "aws_s3_bucket" "s3_bucket" {

  bucket = var.name

  force_destroy       = var.force_destroy_bucket
  object_lock_enabled = var.object_lock_enabled
  tags                = merge(var.tags, local.default_tags)
}

##############################################################
# Public Access Block Settings
##############################################################

resource "aws_s3_bucket_public_access_block" "block_public_access_settings" {
  count = var.block_public_access ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = var.block_public_access_acl
  block_public_policy     = var.block_public_access_policy
  ignore_public_acls      = var.block_public_access_ignore_acl
  restrict_public_buckets = var.block_public_access_restrict_bucket
}

##############################################################
# S3 Access Control List
##############################################################
resource "aws_s3_bucket_acl" "s3_acl" {
  count = (var.acl != null && var.acl != "null") || length(local.grants) > 0 ? 1 : 0

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner

  # hack when `null` value can't be used (eg, from terragrunt, https://github.com/gruntwork-io/terragrunt/pull/1367)
  acl = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(local.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = local.grants

        content {
          permission = grant.value.permission

          grantee {
            type          = grant.value.type
            id            = try(grant.value.id, null)
            uri           = try(grant.value.uri, null)
            email_address = try(grant.value.email, null)
          }
        }
      }

      owner {
        id           = try(var.owner["id"], data.aws_canonical_user_id.this.id)
        display_name = try(var.owner["display_name"], null)
      }
    }
  }

  # This `depends_on` is to prevent "AccessControlListNotSupported: The bucket does not allow ACLs."
  depends_on = [aws_s3_bucket_ownership_controls.this]
}


##############################################################
# S3 Versioning Configuration
##############################################################
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    # Valid values: "Enabled" or "Suspended"
    status = var.versioning ? "Enabled" : "Suspended"
    # Valid values: "Enabled" or "Disabled"
    mfa_delete = var.mfa_delete ? "Enabled" : "Disabled"
  }
}

##############################################################
# S3 Logging Configuration
##############################################################
resource "aws_s3_bucket_logging" "s3_logging" {
  count = var.bucket_logging ? 1 : 0

  bucket        = aws_s3_bucket.s3_bucket.id
  target_bucket = var.logging_bucket_name
  target_prefix = var.logging_bucket_prefix
}

##############################################################
# S3 Server Side Encryption (SSE) Configuration
##############################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  count = var.sse_algorithm == "none" ? 0 : 1

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = try(var.sse_algorithm, "AES256")
      kms_master_key_id = try(var.kms_key_id, null)
    }
    bucket_key_enabled = var.bucket_key_enabled
  }
}

##############################################################
# S3 CORS Configuration
##############################################################
resource "aws_s3_bucket_cors_configuration" "this" {
  count = var.cors ? 1 : 0

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "cors_rule" {
    for_each = local.cors_rules

    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

##############################################################
# S3 Object Lock Configuration
##############################################################
resource "aws_s3_bucket_object_lock_configuration" "this" {
  count = var.object_lock_enabled ? 1 : 0

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner
  token                 = try(var.object_lock_token, null)

  rule {
    default_retention {
      mode  = var.object_lock_mode
      days  = try(var.object_lock_retention_days, null)
      years = try(var.object_lock_retention_years, null)
    }
  }
}

##############################################################
# S3 Website Configuration
##############################################################
resource "aws_s3_bucket_website_configuration" "this" {
  count = var.website ? 1 : 0

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "index_document" {
    for_each = try([var.website_config["index_document"]], [])

    content {
      suffix = index_document.value
    }
  }

  dynamic "error_document" {
    for_each = try([var.website_config["error_document"]], [])

    content {
      key = error_document.value
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = try([var.website_config["redirect_all_requests_to"]], [])

    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = try(redirect_all_requests_to.value.protocol, null)
    }
  }

  dynamic "routing_rule" {
    for_each = try(flatten([var.website_config["routing_rules"]]), [])

    content {
      dynamic "condition" {
        for_each = [try([routing_rule.value.condition], [])]

        content {
          http_error_code_returned_equals = try(routing_rule.value.condition["http_error_code_returned_equals"], null)
          key_prefix_equals               = try(routing_rule.value.condition["key_prefix_equals"], null)
        }
      }

      redirect {
        host_name               = try(routing_rule.value.redirect["host_name"], null)
        http_redirect_code      = try(routing_rule.value.redirect["http_redirect_code"], null)
        protocol                = try(routing_rule.value.redirect["protocol"], null)
        replace_key_prefix_with = try(routing_rule.value.redirect["replace_key_prefix_with"], null)
        replace_key_with        = try(routing_rule.value.redirect["replace_key_with"], null)
      }
    }
  }
}

##############################################################
# S3 Lifecycle Configuration
##############################################################
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.lifecycle_enabled ? 1 : 0

  bucket                = aws_s3_bucket.s3_bucket.id
  expected_bucket_owner = var.expected_bucket_owner

  dynamic "rule" {
    for_each = local.lifecycle_rules

    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Only one rule allowed - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = try([rule.value.abort_incomplete_multipart_upload_days], [])

        content {
          days_after_initiation = try(rule.value.abort_incomplete_multipart_upload_days, null)
        }
      }


      # Only one rule allowed - expiration
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])

        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }

      # Multiple rules allowed - transition
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }

      # Only one rule allowed - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = try(flatten([rule.value.noncurrent_version_expiration]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_expiration.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_expiration.value.days, noncurrent_version_expiration.value.noncurrent_days, null)
        }
      }

      # Multiple rules allowed - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = try(flatten([rule.value.noncurrent_version_transition]), [])

        content {
          newer_noncurrent_versions = try(noncurrent_version_transition.value.newer_noncurrent_versions, null)
          noncurrent_days           = try(noncurrent_version_transition.value.days, noncurrent_version_transition.value.noncurrent_days, null)
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Only one rule allowed - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = length(try(flatten([rule.value.filter]), [])) == 0 ? [true] : []

        content {

        }
      }

      # Only one rule allowed - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) == 1]

        content {
          object_size_greater_than = try(filter.value.object_size_greater_than, null)
          object_size_less_than    = try(filter.value.object_size_less_than, null)
          prefix                   = try(filter.value.prefix, null)

          dynamic "tag" {
            for_each = try(filter.value.tags, filter.value.tag, [])

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Only one rule allowed - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = [for v in try(flatten([rule.value.filter]), []) : v if max(length(keys(v)), length(try(rule.value.filter.tags, rule.value.filter.tag, []))) > 1]

        content {
          and {
            object_size_greater_than = try(filter.value.object_size_greater_than, null)
            object_size_less_than    = try(filter.value.object_size_less_than, null)
            prefix                   = try(filter.value.prefix, null)
            tags                     = try(filter.value.tags, filter.value.tag, null)
          }
        }
      }
    }
  }

  # Requires versioning enabled to build
  depends_on = [aws_s3_bucket_versioning.this]
}

##############################################################
# S3 Intelligent Tiering Configuration
##############################################################
resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  for_each = { for k, v in local.intelligent_tiering : k => v if var.enable_intelligent_tiering }

  name   = each.key
  bucket = aws_s3_bucket.s3_bucket.id
  status = try(tobool(each.value.status) ? "Enabled" : "Disabled", title(lower(each.value.status)), null)

  # Max 1 block - filter
  dynamic "filter" {
    for_each = length(try(flatten([each.value.filter]), [])) == 0 ? [] : [true]

    content {
      prefix = try(each.value.filter.prefix, null)
      tags   = try(each.value.filter.tags, null)
    }
  }

  dynamic "tiering" {
    for_each = each.value.tiering

    content {
      access_tier = tiering.key
      days        = tiering.value.days
    }
  }

}

##############################################################
# S3 Metrics Configuration
##############################################################
resource "aws_s3_bucket_metric" "this" {
  for_each = { for k, v in local.metric_configuration : k => v if var.enable_bucket_metrics }

  name   = each.value.name
  bucket = aws_s3_bucket.s3_bucket.id

  dynamic "filter" {
    for_each = length(try(flatten([each.value.filter]), [])) == 0 ? [] : [true]
    content {
      prefix = try(each.value.filter.prefix, null)
      tags   = try(each.value.filter.tags, null)
    }
  }
}

##############################################################
# S3 Bucket Ownership Control
##############################################################
resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.control_object_ownership ? 1 : 0

  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = var.object_ownership
  }

  # This `depends_on` is to prevent "A conflicting conditional operation is currently in progress against this resource."
  depends_on = [
    aws_s3_bucket_public_access_block.block_public_access_settings,
    aws_s3_bucket.s3_bucket
  ]
}
