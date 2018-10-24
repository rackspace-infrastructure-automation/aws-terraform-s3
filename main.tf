locals {
  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]

  # In order to not have to duplicate resources w/ and w/o web config, this checks and then adds website config as needed.
  bucket_website_config = {
    enabled = [{
      index_document = "${var.website_index}"
      error_document = "${var.website_error}"
    }]

    disabled = "${list()}"
  }

  website_config = "${var.website ? "enabled" : "disabled"}"

  # Standard tags to use and then merge with custom tags.
  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = "${var.environment}"
  }

  merged_tags = "${merge(local.default_tags, var.bucket_tags)}"

  # If object expiration is greater than 0 then add object expiration, otherwise do not add.
  object_expiration = {
    enabled = [{
      days = "${var.object_expiration_days}"
    }]

    disabled = "${list()}"
  }

  object_expiration_config = "${var.object_expiration_days > 0 ? "enabled" : "disabled"}"

  # Enable bucket logging?
  bucket_logging = {
    enabled = [{
      target_bucket = "${var.logging_bucket_name}"
      target_prefix = "${var.logging_bucket_prefix}"
    }]

    disabled = "${list()}"
  }

  bucket_logging_config = "${var.bucket_logging ? "enabled" : "disabled"}"

  # Enable Noncurrent Object Version Expiration?
  noncurrent_version_expiration = {
    enabled = [{
      days = "${var.noncurrent_version_expiration_days}"
    }]

    disabled = "${list()}"
  }

  noncurrent_version_expiration_config = "${var.noncurrent_version_expiration_days > 0 ? "enabled":"disabled"}"

  # Enable File Transitions?
  transition = {
    ia_enabled = [{
      days          = "${var.transition_to_ia_days}"
      storage_class = "STANDARD_IA"
    }]

    glacier_enabled = [{
      days          = "${var.transition_to_glacier_days}"
      storage_class = "GLACIER"
    }]

    disabled = "${list()}"
  }

  ia_transitions      = "${var.transition_to_ia_days > 0 ? "ia_enabled": "disabled"}"
  glacier_transitions = "${var.transition_to_glacier_days > 0 ? "glacier_enabled": "disabled"}"
  transitions         = "${concat(local.transition[local.ia_transitions], local.transition[local.glacier_transitions])}"

  noncurrent_version_transition = {
    ia_enabled = [{
      days          = "${var.noncurrent_version_transition_ia_days}"
      storage_class = "STANDARD_IA"
    }]

    glacier_enabled = [{
      days          = "${var.noncurrent_version_transition_glacier_days}"
      storage_class = "GLACIER"
    }]

    disabled = "${list()}"
  }

  nc_ia_transitions      = "${var.noncurrent_version_transition_ia_days > 0 ? "ia_enabled": "disabled"}"
  nc_glacier_transitions = "${var.noncurrent_version_transition_glacier_days > 0 ? "glacier_enabled":"disabled"}"
  nc_transitions         = "${concat(local.noncurrent_version_transition[local.nc_ia_transitions], local.noncurrent_version_transition[local.nc_glacier_transitions])}"

  # Lifecycle Rules
  lifecycle_rules = {
    enabled = [
      {
        enabled                       = "${var.lifecycle_enabled}"
        prefix                        = "${var.lifecycle_rule_prefix}"
        expiration                    = "${local.object_expiration[local.object_expiration_config]}"
        noncurrent_version_expiration = "${local.noncurrent_version_expiration[local.noncurrent_version_expiration_config]}"

        transition = "${local.transitions}"

        noncurrent_version_transition = "${local.nc_transitions}"
      },
    ]

    disabled = "${list()}"
  }

  lifecycle_rules_config = "${var.lifecycle_enabled ? "enabled":"disabled"}"

  # CORS rules
  cors_rules = {
    enabled = [
      {
        allowed_origins = ["${var.allowed_origins}"]
        allowed_methods = ["${var.allowed_methods}"]
        expose_headers  = ["${var.expose_headers}"]
        allowed_headers = ["${var.allowed_headers}"]
        max_age_seconds = "${var.max_age_seconds}"
      },
    ]

    disabled = "${list()}"
  }

  cors_rules_config = "${length(var.allowed_origins) > 0 ? "enabled":"disabled"}"

  # SSE Rule Configuration
  server_side_encryption_rule = {
    enabled = [
      {
        rule = [{
          apply_server_side_encryption_by_default = [
            {
              kms_master_key_id = "${var.kms_master_key_id}"
              sse_algorithm     = "${var.sse_algorithm}"
            },
          ]
        }]
      },
    ]

    disabled = "${list()}"
  }

  server_side_encryption_rule_config = "${var.sse_algorithm == "none" ? "disabled" : "enabled"}"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = "${var.bucket_name}"
  acl    = "${contains(local.acl_list, var.bucket_acl) ? var.bucket_acl:"ACL_ERROR"}"

  tags = "${local.merged_tags}"

  server_side_encryption_configuration = ["${local.server_side_encryption_rule[local.server_side_encryption_rule_config]}"]

  website = "${local.bucket_website_config[local.website_config]}"

  logging = "${local.bucket_logging[local.bucket_logging_config]}"

  versioning {
    enabled = "${var.versioning}"
  }

  lifecycle_rule = "${local.lifecycle_rules[local.lifecycle_rules_config]}"

  cors_rule = "${local.cors_rules[local.cors_rules_config]}"
}
