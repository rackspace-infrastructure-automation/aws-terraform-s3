###
# This test adds the 'CORS Rules' configuration variables
###

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}

resource "random_string" "s3_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "s3" {
  source = "../../module"

  bucket_acl                                 = "private"
  bucket_logging                             = false
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  transition_to_glacier_days                 = "60"
  transition_to_ia_days                      = "30"
  versioning                                 = true
  website                                    = true
  website_error                              = "error.html"
  website_index                              = "index.html"
  cors                                       = true
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

  #  Not defining these to ensure it can properly handle undefined variable lists or strings
  #  expose_headers  = ["Accept-Ranges", "Content-Range", "Content-Encoding", "Content-Length"]

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}
