terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"

    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "random_string" "s3_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "s3_basic" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"

  bucket_logging    = false
  bucket_acl        = "private"
  environment       = "Development"
  name              = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning        = true
  lifecycle_enabled = true
  lifecycle_rule = [
    {
      id                                     = "Default MPU Cleanup Rule."
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7
    }
  ]

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}


module "s3_website_with_cors" {
  # Websites and CORS have undergone a significant refactor since v0.12.7 due to features that added to their complexity.
  # Follow this example if you are using v0.12.10+
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"

  bucket_acl     = "private"
  bucket_logging = false
  environment    = "Development"
  name           = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning     = true
  website        = true
  website_config = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = [{
      condition = {
        key_prefix_equals = "docs/"
      },
      redirect = {
        replace_key_prefix_with = "documents/"
      }
      }, {
      condition = {
        http_error_code_returned_equals = 404
        key_prefix_equals               = "archive/"
      },
      redirect = {
        host_name          = "example.com"
        http_redirect_code = 301
        protocol           = "https"
        replace_key_with   = "not_found.html"
      }
    }]
  }
  cors = true
  cors_rule = [
    {
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
      }, {
      allowed_methods = ["PUT"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}

module "s3_object_lock" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"

  bucket_acl                 = "private"
  bucket_logging             = false
  environment                = "Development"
  name                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  object_lock_enabled        = true
  object_lock_mode           = "GOVERNANCE"
  object_lock_retention_days = 1
  versioning                 = true

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}

module "s3_with_lifecycle" {
  # Lifecycle has undergone a significant refactor since v0.12.7 due to features that added to their complexity.
  # Follow this example if you are using v0.12.10+
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"

  bucket_acl        = "private"
  bucket_logging    = false
  environment       = "Development"
  name              = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning        = true
  lifecycle_enabled = true
  lifecycle_rule = [
    {
      id      = "log"
      enabled = true

      filter = {
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    },
    {
      id                                     = "Default MPU Cleanup Rule."
      enabled                                = true
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
    {
      id      = "log2"
      enabled = true

      filter = {
        prefix                   = "log1/"
        object_size_greater_than = 200000
        object_size_less_than    = 500000
        tags = {
          some    = "value"
          another = "value2"
        }
      }

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
  ]

  intelligent_tiering = {
    general = {
      status = "Enabled"
      filter = {
        prefix = "/"
        tags = {
          Environment = "dev"
        }
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 180
        }
      }
    },
    documents = {
      status = false
      filter = {
        prefix = "documents/"
      }
      tiering = {
        ARCHIVE_ACCESS = {
          days = 125
        }
        DEEP_ARCHIVE_ACCESS = {
          days = 200
        }
      }
    }
  }

  metric_configuration = [
    {
      name = "documents"
      filter = {
        prefix = "documents/"
        tags = {
          priority = "high"
        }
      }
    },
    {
      name = "other"
      filter = {
        tags = {
          production = "true"
        }
      }
    },
    {
      name = "all"
    }
  ]
}
