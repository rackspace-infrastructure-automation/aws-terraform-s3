###
# SSE, bucket key test, and intelligent tiering test
###

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
  length  = 16
  special = false
  upper   = false
}

module "s3" {
  source = "../../module"

  bucket_acl                 = "private"
  bucket_logging             = false
  environment                = "Development"
  name                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning                 = true
  kms_key_id                 = "aws/s3"
  sse_algorithm              = "aws:kms"
  enable_intelligent_tiering = true
  bucket_key_enabled         = true

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }

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
}
