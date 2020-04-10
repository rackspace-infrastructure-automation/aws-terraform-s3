/**
 * # aws-terraform-s3
 *
 * This module builds a s3 bucket with varying options.
 * It will not do s3 origin, which is in another module.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "s3" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.0"
 *
 *   bucket_acl                                 = "bucket-owner-full-control"
 *   bucket_logging                             = false
 *   environment                                = "Development"
 *   lifecycle_enabled                          = true
 *   name                                       = "${random_string.s3_rstring.result}-example-s3-bucket"
 *   noncurrent_version_expiration_days         = "425"
 *   noncurrent_version_transition_glacier_days = "60"
 *   noncurrent_version_transition_ia_days      = "30"
 *   object_expiration_days                     = "425"
 *   transition_to_glacier_days                 = "60"
 *   transition_to_ia_days                      = "30"
 *   versioning                                 = true
 *   website                                    = true
 *   website_error                              = "error.html"
 *   website_index                              = "index.html"
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

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

locals {

  ##############################################################
  # Bucket local variables
  ##############################################################

  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]

  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  ##############################################################
  # CORS rules local variables
  ##############################################################

  cors_rules = {
    enabled = [
      {
        allowed_headers = var.allowed_headers
        allowed_methods = var.allowed_methods
        allowed_origins = var.allowed_origins
        expose_headers  = var.expose_headers
        max_age_seconds = var.max_age_seconds
      },
    ]
    disabled = []
  }

  ##############################################################
  # Lifecycle Rules local variables
  ##############################################################

  lifecycle_rules = {
    enabled = [
      {
        enabled                       = var.lifecycle_enabled
        expiration                    = local.object_expiration[var.object_expiration_days > 0 ? "enabled" : "disabled"]
        noncurrent_version_expiration = local.noncurrent_version_expiration[var.noncurrent_version_expiration_days > 0 ? "enabled" : "disabled"]
        prefix                        = var.lifecycle_rule_prefix

        noncurrent_version_transition = concat(
          local.noncurrent_version_transition[var.noncurrent_version_transition_ia_days > 0 ? "ia_enabled" : "disabled"],
          local.noncurrent_version_transition[var.noncurrent_version_transition_glacier_days > 0 ? "glacier_enabled" : "disabled"],
        )

        transition = concat(
          local.transition[var.transition_to_ia_days > 0 ? "ia_enabled" : "disabled"],
          local.transition[var.transition_to_glacier_days > 0 ? "glacier_enabled" : "disabled"],
        )
      },
    ]
    disabled = []
  }

  object_expiration = {
    enabled  = [{ days = var.object_expiration_days }]
    disabled = []
  }

  noncurrent_version_expiration = {
    enabled  = [{ days = var.noncurrent_version_expiration_days }]
    disabled = []
  }

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

  ##############################################################
  # Bucket Logging local variables
  ##############################################################

  bucket_logging = {
    enabled = [
      {
        target_bucket = var.logging_bucket_name
        target_prefix = var.logging_bucket_prefix
      },
    ]
    disabled = []
  }

  ##############################################################
  # Server side encryption rule local variables
  ##############################################################

  server_side_encryption_rule = {
    enabled = [
      {
        rule = [
          {
            apply_server_side_encryption_by_default = [
              {
                kms_master_key_id = var.kms_key_id
                sse_algorithm     = var.sse_algorithm
              },
            ]
          },
        ]
      },
    ]
    disabled = []
  }

  ##############################################################
  # Bucket website local variables
  ##############################################################

  bucket_website_config = {
    enabled = [
      {
        index_document = var.website_index
        error_document = var.website_error
      },
    ]
    disabled = []
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  acl           = contains(local.acl_list, var.bucket_acl) ? var.bucket_acl : "ACL_ERROR"
  bucket        = var.name
  force_destroy = var.force_destroy_bucket
  tags          = merge(var.tags, local.default_tags)

  dynamic "cors_rule" {
    for_each = local.cors_rules[length(var.allowed_origins) > 0 ? "enabled" : "disabled"]
    content {
      allowed_headers = lookup(cors_rule.value, "allowed_headers", null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = lookup(cors_rule.value, "expose_headers", null)
      max_age_seconds = lookup(cors_rule.value, "max_age_seconds", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = local.lifecycle_rules[(var.lifecycle_enabled ? "enabled" : "disabled")]
    content {
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
          days = noncurrent_version_expiration.value.days
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(lifecycle_rule.value, "noncurrent_version_transition", [])
        content {
          days          = noncurrent_version_transition.value.days
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

  dynamic "logging" {
    for_each = local.bucket_logging[var.bucket_logging ? "enabled" : "disabled"]
    content {
      target_bucket = logging.value.target_bucket
      target_prefix = lookup(logging.value, "target_prefix", null)
    }
  }

  dynamic "server_side_encryption_configuration" {
    for_each = local.server_side_encryption_rule[var.sse_algorithm == "none" ? "disabled" : "enabled"]
    content {
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

  versioning {
    enabled = var.versioning
  }

  dynamic "website" {
    for_each = local.bucket_website_config[var.website ? "enabled" : "disabled"]
    content {
      error_document           = lookup(website.value, "error_document", null)
      index_document           = lookup(website.value, "index_document", null)
      redirect_all_requests_to = lookup(website.value, "redirect_all_requests_to", null)
      routing_rules            = lookup(website.value, "routing_rules", null)
    }
  }
}
