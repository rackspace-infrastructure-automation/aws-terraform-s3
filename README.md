# aws-terraform-s3

This module builds a s3 bucket with varying options.  
It will not do s3 origin, which is in another module.

## Basic Usage

```HCL
module "s3" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.3"

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

  tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
}
```

Full working references are available at [examples](examples)

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should be  
made when upgrading from a previous release to version 0.12.0 or higher.

### Module variables

The following module variables were updated to better meet current Rackspace style guides:

- `bucket_name` -> `name`
- `kms_master_key_id` -> `kms_key_id`
- `bucket_tags` -> `tags`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.7.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/s3_bucket) |
| [aws_s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/2.7.0/docs/resources/s3_bucket_public_access_block) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allowed\_headers | Specifies which headers are allowed. | `list(string)` | `[]` | no |
| allowed\_methods | (Required) Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD. | `list(string)` | `[]` | no |
| allowed\_origins | (Required) Specifies which origins are allowed. | `list(string)` | `[]` | no |
| block\_public\_access | Block various forms of public access on a per bucket level | `bool` | `false` | no |
| block\_public\_access\_acl | Related to block\_public\_access. PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL. | `bool` | `true` | no |
| block\_public\_access\_ignore\_acl | Related to block\_public\_access. Ignore public ACLs on this bucket and any objects that it contains. | `bool` | `true` | no |
| block\_public\_access\_policy | Related to block\_public\_access. Reject calls to PUT Bucket policy if the specified bucket policy allows public access. | `bool` | `true` | no |
| block\_public\_access\_restrict\_bucket | Related to block\_public\_access. Only the bucket owner and AWS Services can access this buckets if it has a public policy. | `bool` | `true` | no |
| bucket\_acl | Bucket ACL. Must be either authenticated-read, aws-exec-read, log-delivery-write, private, public-read or public-read-write. For more details https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | `string` | `"private"` | no |
| bucket\_logging | Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ\_ACP permissions to the target bucket. i.e. true \| false | `bool` | `false` | no |
| environment | Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test'] | `string` | `"Development"` | no |
| expose\_headers | Specifies expose header in the response. | `list(string)` | `[]` | no |
| force\_destroy\_bucket | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| kms\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. | `string` | `""` | no |
| lifecycle\_enabled | Enable object lifecycle management. i.e. true \| false | `bool` | `false` | no |
| lifecycle\_rule\_prefix | Object keyname prefix identifying one or more objects to which the rule applies. Set as an empty string to target the whole bucket. | `string` | `""` | no |
| logging\_bucket\_name | Name of the existing bucket where the logs will be stored. | `string` | `""` | no |
| logging\_bucket\_prefix | Prefix for all log object keys. i.e. logs/ | `string` | `""` | no |
| max\_age\_seconds | Specifies time in seconds that browser can cache the response for a preflight request. | `number` | `600` | no |
| name | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). Must be globally unique. If changed, forces a new resource. | `string` | n/a | yes |
| noncurrent\_version\_expiration\_days | Indicates after how many days we are deleting previous version of objects.  Set to 0 to disable or at least 365 days longer than noncurrent\_version\_transition\_glacier\_days. i.e. 0 to disable, 1-999 otherwise | `number` | `0` | no |
| noncurrent\_version\_transition\_glacier\_days | Indicates after how many days we are moving previous versions to Glacier.  Should be 0 to disable or at least 30 days longer than noncurrent\_version\_transition\_ia\_days. i.e. 0 to disable, 1-999 otherwise | `number` | `0` | no |
| noncurrent\_version\_transition\_ia\_days | Indicates after how many days we are moving previous version objects to Standard-IA storage. Set to 0 to disable. | `number` | `0` | no |
| object\_expiration\_days | Indicates after how many days we are deleting current version of objects. Set to 0 to disable or at least 365 days longer than TransitionInDaysGlacier. i.e. 0 to disable, otherwise 1-999 | `number` | `0` | no |
| object\_lock\_enabled | Indicates whether this bucket has an Object Lock configuration enabled. Disabled by default. You can only enable S3 Object Lock for new buckets. If you need to turn on S3 Object Lock for an existing bucket, please contact AWS Support. | `bool` | `false` | no |
| object\_lock\_mode | The default Object Lock retention mode you want to apply to new objects placed in this bucket. Valid values are GOVERNANCE and COMPLIANCE. Default is GOVERNANCE (allows administrative override). | `string` | `"GOVERNANCE"` | no |
| object\_lock\_retention\_days | The retention of the object lock in days. Either days or years must be specified, but not both. | `number` | `null` | no |
| object\_lock\_retention\_years | The retention of the object lock in years. Either days or years must be specified, but not both. | `number` | `null` | no |
| rax\_mpu\_cleanup\_enabled | Enable Rackspace default values for cleanup of Multipart Uploads. | `bool` | `true` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are AES256, aws:kms, and none | `string` | `"AES256"` | no |
| tags | A map of tags to be applied to the Bucket. i.e {Environment='Development'} | `map(string)` | `{}` | no |
| transition\_to\_glacier\_days | Indicates after how many days we are moving current versions to Glacier.  Should be 0 to disable or at least 30 days longer than transition\_to\_ia\_days. i.e. 0 to disable, otherwise 1-999 | `number` | `0` | no |
| transition\_to\_ia\_days | Indicates after how many days we are moving current objects to Standard-IA storage. i.e. 0 to disable, otherwise 1-999 | `number` | `0` | no |
| versioning | Enable bucket versioning. i.e. true \| false | `bool` | `false` | no |
| website | Use bucket as a static website. i.e. true \| false | `bool` | `false` | no |
| website\_error | Location of Error HTML file. i.e. error.html | `string` | `"error.html"` | no |
| website\_index | Location of Index HTML file. i.e index.html | `string` | `"index.html"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| bucket\_id | The name of the bucket. |
| bucket\_region | The AWS region this bucket resides in. |
| bucket\_website\_domain | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. |
| bucket\_website\_endpoint | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
