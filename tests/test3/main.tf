###
# This test adds the sse_algorithm option 'none' and disabled MPU cleanup
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
  rax_mpu_cleanup_enabled                    = false
  sse_algorithm                              = "none"
  transition_to_glacier_days                 = "60"
  transition_to_ia_days                      = "30"
  versioning                                 = true
  website                                    = true
  website_error                              = "error.html"
  website_index                              = "index.html"

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}

module "s3_logging_test" {
  source = "../../module"

  bucket_acl                                 = "private"
  bucket_logging                             = true
  logging_bucket_name                        = module.s3.bucket_id
  logging_bucket_prefix                      = "logs/"
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-log-bucket"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  rax_mpu_cleanup_enabled                    = true
  transition_to_glacier_days                 = "60"
  transition_to_ia_days                      = "30"
  versioning                                 = true
  kms_key_id                                 = "aws/s3"
  sse_algorithm                              = "aws:kms"
  bucket_key_enabled                         = true


  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }

  depends_on = [module.s3]
}
