###
# Website with CORS rules test
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

  control_object_ownership = true
  acl                      = "private"
  bucket_logging           = false
  environment              = "Development"
  name                     = "${random_string.s3_rstring.result}-example-s3-bucket"
  versioning               = true
  website                  = true
  website_config           = {
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
