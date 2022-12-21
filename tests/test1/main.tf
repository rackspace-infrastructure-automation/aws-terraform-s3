###
# Basic bucket test
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

  bucket_acl        = "private"
  bucket_logging    = false
  environment       = "Development"
  name              = "${random_string.s3_rstring.result}-example-s3-bucket"
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
