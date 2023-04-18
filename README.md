# aws-terraform-s3

This module builds a s3 bucket with varying options.  
It will not do s3 origin, which is in another module.

## Basic Usage

```HCL
module "s3_basic" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.12.12"

  bucket_logging    = false
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
| terraform | >= 0.13 |
| aws | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 4.0 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_canonical_user_id](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/data-sources/canonical_user_id) |
| [aws_s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket) |
| [aws_s3_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_acl) |
| [aws_s3_bucket_cors_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_cors_configuration) |
| [aws_s3_bucket_intelligent_tiering_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_intelligent_tiering_configuration) |
| [aws_s3_bucket_lifecycle_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_lifecycle_configuration) |
| [aws_s3_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_logging) |
| [aws_s3_bucket_metric](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_metric) |
| [aws_s3_bucket_object_lock_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_object_lock_configuration) |
| [aws_s3_bucket_ownership_controls](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_ownership_controls) |
| [aws_s3_bucket_public_access_block](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_public_access_block) |
| [aws_s3_bucket_server_side_encryption_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_server_side_encryption_configuration) |
| [aws_s3_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_versioning) |
| [aws_s3_bucket_website_configuration](https://registry.terraform.io/providers/hashicorp/aws/4.0/docs/resources/s3_bucket_website_configuration) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acl | (Optional) The canned ACL to apply. Conflicts with `grant` | `string` | `null` | no |
| block\_public\_access | Block various forms of public access on a per bucket level | `bool` | `false` | no |
| block\_public\_access\_acl | Related to block\_public\_access. PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL. | `bool` | `true` | no |
| block\_public\_access\_ignore\_acl | Related to block\_public\_access. Ignore public ACLs on this bucket and any objects that it contains. | `bool` | `true` | no |
| block\_public\_access\_policy | Related to block\_public\_access. Reject calls to PUT Bucket policy if the specified bucket policy allows public access. | `bool` | `true` | no |
| block\_public\_access\_restrict\_bucket | Related to block\_public\_access. Only the bucket owner and AWS Services can access this buckets if it has a public policy. | `bool` | `true` | no |
| bucket\_key\_enabled | Whether or not to use Amazon S3 Bucket Keys for SSE-KMS. | `bool` | `false` | no |
| bucket\_logging | Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ\_ACP permissions to the target bucket. i.e. true \| false | `bool` | `false` | no |
| control\_object\_ownership | Whether to manage S3 Bucket Ownership Controls on this bucket. | `bool` | `false` | no |
| cors | Enable CORS Rules. Rules must be defined in the variable cors\_rules | `bool` | `false` | no |
| cors\_rule | List of maps containing rules for Cross-Origin Resource Sharing. | `any` | `[]` | no |
| enable\_bucket\_metrics | Enable bucket metrics | `bool` | `false` | no |
| enable\_intelligent\_tiering | Enable intelligent tiering | `bool` | `false` | no |
| environment | Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test'] | `string` | `"Development"` | no |
| expected\_bucket\_owner | The account ID of the expected bucket owner | `string` | `null` | no |
| force\_destroy\_bucket | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| grant | An ACL policy grant. Conflicts with `acl` | `any` | `[]` | no |
| intelligent\_tiering | Map containing intelligent tiering configuration. | `any` | `{}` | no |
| kms\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. | `string` | `null` | no |
| lifecycle\_enabled | Enable object lifecycle management. i.e. true \| false | `bool` | `false` | no |
| lifecycle\_rule | List of maps containing configuration of object lifecycle management. | `any` | `[]` | no |
| logging\_bucket\_name | Name of the existing bucket where the logs will be stored. | `string` | `""` | no |
| logging\_bucket\_prefix | Prefix for all log object keys. i.e. logs/ | `string` | `""` | no |
| metric\_configuration | Map containing bucket metric configuration. | `any` | `[]` | no |
| mfa\_delete | Specifies whether MFA delete is enabled in the bucket versioning configuration | `bool` | `false` | no |
| name | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). Must be globally unique. If changed, forces a new resource. | `string` | n/a | yes |
| object\_expiration\_days | Indicates after how many days we are deleting current version of objects. Set to 0 to disable or at least 365 days longer than TransitionInDaysGlacier. i.e. 0 to disable, otherwise 1-999 | `number` | `0` | no |
| object\_lock\_enabled | Indicates whether this bucket has an Object Lock configuration enabled. Disabled by default. You can only enable S3 Object Lock for new buckets. If you need to turn on S3 Object Lock for an existing bucket, please contact AWS Support. | `bool` | `false` | no |
| object\_lock\_mode | The default Object Lock retention mode you want to apply to new objects placed in this bucket. Valid values are GOVERNANCE and COMPLIANCE. Default is GOVERNANCE (allows administrative override). | `string` | `"GOVERNANCE"` | no |
| object\_lock\_retention\_days | The retention of the object lock in days. Either days or years must be specified, but not both. | `number` | `null` | no |
| object\_lock\_retention\_years | The retention of the object lock in years. Either days or years must be specified, but not both. | `number` | `null` | no |
| object\_lock\_token | A token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's 'Object Lock token'. The token is generated in the back-end when versioning is enabled on a bucket. | `string` | `null` | no |
| object\_ownership | Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL. | `string` | `"ObjectWriter"` | no |
| owner | Bucket owner's display name and ID. Conflicts with `acl` | `map(string)` | `{}` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are AES256, aws:kms, and none | `string` | `"AES256"` | no |
| tags | A map of tags to be applied to the Bucket. i.e {Environment='Development'} | `map(string)` | `{}` | no |
| versioning | Enable bucket versioning. | `bool` | `false` | no |
| website | Use bucket as a static website. i.e. true \| false | `bool` | `false` | no |
| website\_config | Map containing static web-site hosting or redirect configuration. | `any` | `{}` | no |

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
