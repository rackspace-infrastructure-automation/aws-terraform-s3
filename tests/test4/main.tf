###
# SSE & bucket key test
###

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"

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

  bucket_acl         = "private"
  bucket_logging     = false
  environment        = "Development"
  name               = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning         = true
  kms_key_id         = "aws/s3"
  sse_algorithm      = "aws:kms"
  bucket_key_enabled = true

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}