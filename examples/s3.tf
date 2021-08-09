terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

resource "random_string" "s3_rstring" {
  length  = 18
  special = false
  upper   = false
}

module "s3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.8"

  bucket_logging                             = false
  bucket_acl                                 = "private"
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  object_lock_enabled                        = true
  object_lock_mode                           = "GOVERNANCE"
  object_lock_retention_days                 = 1
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


module "s3_no_website" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.8"

  bucket_logging                             = false
  bucket_acl                                 = "private"
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-bucket-no-web"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  transition_to_glacier_days                 = "60"
  transition_to_ia_days                      = "30"
  versioning                                 = true
  website                                    = false

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}

module "s3_object_lock" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.8"

  bucket_acl                                 = "private"
  bucket_logging                             = false
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  object_lock_enabled                        = true
  object_lock_mode                           = "GOVERNANCE"
  object_lock_retention_days                 = 1
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

module "s3_bucket_with_policy" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.8"

  bucket_acl                                 = "private"
  bucket_logging                             = false
  environment                                = "Development"
  lifecycle_enabled                          = true
  name                                       = "${random_string.s3_rstring.result}-example-s3-bucket"
  noncurrent_version_expiration_days         = "425"
  noncurrent_version_transition_glacier_days = "60"
  noncurrent_version_transition_ia_days      = "30"
  object_expiration_days                     = "425"
  object_lock_enabled                        = true
  object_lock_mode                           = "GOVERNANCE"
  object_lock_retention_days                 = 1
  rax_mpu_cleanup_enabled                    = false
  sse_algorithm                              = "none"
  transition_to_glacier_days                 = "60"
  transition_to_ia_days                      = "30"
  versioning                                 = true
  website                                    = true
  website_error                              = "error.html"
  website_index                              = "index.html"


  ownership_controls = "BucketOwnerPreferred"
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Id      = "CloudTrailBucketPolicy"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = module.s3_bucket_with_policy.bucket_arn
      }
    ]
  })


  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}
