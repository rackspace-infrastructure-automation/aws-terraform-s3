/**
 * # aws-terraform-s3
 *
 *This module builds a s3 bucket with varying options.
 *It will not do s3 origin, which is in another module.
 *
 *## Basic Usage
 *
 *```
 *module "s3" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.0.4"
 *  bucket_name = "${random_string.s3_rstring.result}-example-s3-bucket"
 *  bucket_acl = "bucket-owner-full-control"
 *  bucket_logging = false
 *  bucket_tags = {
 *    RightSaid = "Fred"
 *    LeftSaid  = "George"
 *  }
 *  environment = "Development"
 *  lifecycle_enabled = true
 *  noncurrent_version_expiration_days = "425"
 *  noncurrent_version_transition_glacier_days = "60"
 *  noncurrent_version_transition_ia_days = "30"
 *  object_expiration_days = "425"
 *  transition_to_glacier_days = "60"
 *  transition_to_ia_days = "30"
 *  versioning = true
 *  website = true
 *  website_error = "error.html"
 *  website_index = "index.html"
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.0.0"
  }
}

locals {
  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]

  # In order to not have to duplicate resources w/ and w/o web config, this checks and then adds website config as needed.
  bucket_website_config = {
    enabled = [
      {
        index_document = var.website_index
        error_document = var.website_error
      },
    ]
    disabled = []
  }

  website_config = var.website ? "enabled" : "disabled"

  # Standard tags to use and then merge with custom tags.
  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  merged_tags = merge(local.default_tags, var.bucket_tags)

  # If object expiration is greater than 0 then add object expiration, otherwise do not add.
  object_expiration = {
    enabled = [
      {
        days = var.object_expiration_days
      },
    ]
    disabled = []
  }

  object_expiration_config = var.object_expiration_days > 0 ? "enabled" : "disabled"

  # Enable bucket logging?
  bucket_logging = {
    enabled = [
      {
        target_bucket = var.logging_bucket_name
        target_prefix = var.logging_bucket_prefix
      },
    ]
    disabled = []
  }

  bucket_logging_config = var.bucket_logging ? "enabled" : "disabled"

  # Enable Noncurrent Object Version Expiration?
  noncurrent_version_expiration = {
    enabled = [
      {
        days = var.noncurrent_version_expiration_days
      },
    ]
    disabled = []
  }

  noncurrent_version_expiration_config = var.noncurrent_version_expiration_days > 0 ? "enabled" : "disabled"

  # Enable File Transitions?
  transition = {
    ia_enabled = [
      {
        days          = var.transition_to_ia_days
        storage_class = "STANDARD_IA"
      },
    ]
    glacier_enabled = [
      {
        days          = var.transition_to_glacier_days
        storage_class = "GLACIER"
      },
    ]
    disabled = []
  }

  ia_transitions      = var.transition_to_ia_days > 0 ? "ia_enabled" : "disabled"
  glacier_transitions = var.transition_to_glacier_days > 0 ? "glacier_enabled" : "disabled"
  transitions = concat(
    local.transition[local.ia_transitions],
    local.transition[local.glacier_transitions],
  )

  noncurrent_version_transition = {
    ia_enabled = [
      {
        days          = var.noncurrent_version_transition_ia_days
        storage_class = "STANDARD_IA"
      },
    ]
    glacier_enabled = [
      {
        days          = var.noncurrent_version_transition_glacier_days
        storage_class = "GLACIER"
      },
    ]
    disabled = []
  }

  nc_ia_transitions      = var.noncurrent_version_transition_ia_days > 0 ? "ia_enabled" : "disabled"
  nc_glacier_transitions = var.noncurrent_version_transition_glacier_days > 0 ? "glacier_enabled" : "disabled"
  nc_transitions = concat(
    local.noncurrent_version_transition[local.nc_ia_transitions],
    local.noncurrent_version_transition[local.nc_glacier_transitions],
  )

  # Lifecycle Rules
  lifecycle_rules = {
    enabled = [
      {
        enabled                       = var.lifecycle_enabled
        prefix                        = var.lifecycle_rule_prefix
        expiration                    = local.object_expiration[local.object_expiration_config]
        noncurrent_version_expiration = local.noncurrent_version_expiration[local.noncurrent_version_expiration_config]
        transition                    = local.transitions
        noncurrent_version_transition = local.nc_transitions
      },
    ]
    disabled = []
  }

  lifecycle_rules_config = var.lifecycle_enabled ? "enabled" : "disabled"

  # CORS rules
  cors_rules = {
    enabled = [
      {
        allowed_origins = [var.allowed_origins]
        allowed_methods = [var.allowed_methods]
        expose_headers  = [var.expose_headers]
        allowed_headers = [var.allowed_headers]
        max_age_seconds = var.max_age_seconds
      },
    ]
    disabled = []
  }

  cors_rules_config = length(var.allowed_origins) > 0 ? "enabled" : "disabled"

  # SSE Rule Configuration
  server_side_encryption_rule = {
    enabled = [
      {
        rule = [
          {
            apply_server_side_encryption_by_default = [
              {
                kms_master_key_id = var.kms_master_key_id
                sse_algorithm     = var.sse_algorithm
              },
            ]
          },
        ]
      },
    ]
    disabled = []
  }

  server_side_encryption_rule_config = var.sse_algorithm == "none" ? "disabled" : "enabled"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = contains(local.acl_list, var.bucket_acl) ? var.bucket_acl : "ACL_ERROR"

  tags = local.merged_tags

  dynamic "server_side_encryption_configuration" {
    for_each = [local.server_side_encryption_rule[local.server_side_encryption_rule_config]]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      dynamic "rule" {
        for_each = lookup(server_side_encryption_configuration.value, "rule", [])
        content {
          dynamic "apply_server_side_encryption_by_default" {
            for_each = lookup(rule.value, "apply_server_side_encryption_by_default", [])
            content {
              kms_master_key_id = lookup(apply_server_side_encryption_by_default.value, "kms_master_key_id", null)
              sse_algorithm     = apply_server_side_encryption_by_default.value.sse_algorithm
            }
          }
        }
      }
    }
  }

  dynamic "website" {
    for_each = local.bucket_website_config[local.website_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      error_document           = lookup(website.value, "error_document", null)
      index_document           = lookup(website.value, "index_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }

  dynamic "logging" {
    for_each = local.bucket_logging[local.bucket_logging_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  versioning {
    enabled = var.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = local.lifecycle_rules[local.lifecycle_rules_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      abort_incomplete_multipart_upload_days = lookup(lifecycle_rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = lifecycle_rule.value.enabled
      id                                     = lookup(lifecycle_rule.value, "id", null)
      prefix                                 = lookup(lifecycle_rule.value, "prefix", null)
      tags                                   = lookup(lifecycle_rule.value, "tags", null)

      dynamic "expiration" {
        for_each = lookup(lifecycle_rule.value, "expiration", [])
        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_expiration", [])
        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "transition" {
        for_each = lookup(lifecycle_rule.value, "transition", [])
        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  dynamic "cors_rule" {
    for_each = local.cors_rules[local.cors_rules_config]
    content {
      # TF-UPGRADE-TODO: The automatic upgrade tool can't predict
      # which keys might be set in maps assigned here, so it has
      # produced a comprehensive set here. Consider simplifying
      # this after confirming which keys can be set in practice.

      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  force_destroy = var.force_destroy_bucket
}
