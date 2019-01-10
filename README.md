# aws-terraform-s3

This module builds a s3 bucket with varying options.
It will not do s3 origin, which is in another module.

## Basic Usage

```
module "s3" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-s3//?ref=v0.0.4"
 bucket_name = "${random_string.s3_rstring.result}-example-s3-bucket"
 bucket_acl = "bucket-owner-full-control"
 bucket_logging = false
 bucket_tags = {
   RightSaid = "Fred"
   LeftSaid  = "George"
 }
 environment = "Development"
 lifecycle_enabled = true
 noncurrent_version_expiration_days = "425"
 noncurrent_version_transition_glacier_days = "60"
 noncurrent_version_transition_ia_days = "30"
 object_expiration_days = "425"
 transition_to_glacier_days = "60"
 transition_to_ia_days = "30"
 versioning = true
 website = true
 website_error = "error.html"
 website_index = "index.html"
}
```

Full working references are available at [examples](examples)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_headers | Specifies which headers are allowed. | list | `<list>` | no |
| allowed\_methods | (Required) Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD. | list | `<list>` | no |
| allowed\_origins | (Required) Specifies which origins are allowed. | list | `<list>` | no |
| bucket\_acl | Bucket ACL. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. For more details https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | string | `"bucket-owner-full-control"` | no |
| bucket\_logging | Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ_ACP permissions to the target bucket. i.e. true | false | string | `"false"` | no |
| bucket\_name | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). Must be globally unique. If changed, forces a new resource. | string | n/a | yes |
| bucket\_tags | A map of tags to be applied to the Bucket. i.e {Environment='Development'} | map | `<map>` | no |
| environment | Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test'] | string | `"Development"` | no |
| expose\_headers | Specifies expose header in the response. | list | `<list>` | no |
| force\_destroy\_bucket | A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | string | `"false"` | no |
| kms\_master\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. | string | `""` | no |
| lifecycle\_enabled | Enable object lifecycle management. i.e. true | false | string | `"false"` | no |
| lifecycle\_rule\_prefix | Object keyname prefix identifying one or more objects to which the rule applies. Set as an empty string to target the whole bucket. | string | `""` | no |
| logging\_bucket\_name | Name of the existing bucket where the logs will be stored. | string | `""` | no |
| logging\_bucket\_prefix | Prefix for all log object keys. i.e. logs/ | string | `""` | no |
| max\_age\_seconds | Specifies time in seconds that browser can cache the response for a preflight request. | string | `"600"` | no |
| noncurrent\_version\_expiration\_days | Indicates after how many days we are deleting previous version of objects.  Set to 0 to disable or at least 365 days longer than noncurrent_version_transition_glacier_days. i.e. 0 to disable, 1-999 otherwise | string | `"0"` | no |
| noncurrent\_version\_transition\_glacier\_days | Indicates after how many days we are moving previous versions to Glacier.  Should be 0 to disable or at least 30 days longer than noncurrent_version_transition_ia_days. i.e. 0 to disable, 1-999 otherwise | string | `"0"` | no |
| noncurrent\_version\_transition\_ia\_days | Indicates after how many days we are moving previous version objects to Standard-IA storage. Set to 0 to disable. | string | `"0"` | no |
| object\_expiration\_days | Indicates after how many days we are deleting current version of objects. Set to 0 to disable or at least 365 days longer than TransitionInDaysGlacier. i.e. 0 to disable, otherwise 1-999 | string | `"0"` | no |
| sse\_algorithm | The server-side encryption algorithm to use. Valid values are AES256, aws:kms, and none | string | `"AES256"` | no |
| transition\_to\_glacier\_days | Indicates after how many days we are moving current versions to Glacier.  Should be 0 to disable or at least 30 days longer than transition_to_ia_days. i.e. 0 to disable, otherwise 1-999 | string | `"0"` | no |
| transition\_to\_ia\_days | Indicates after how many days we are moving current objects to Standard-IA storage. i.e. 0 to disable, otherwise 1-999 | string | `"0"` | no |
| versioning | Enable bucket versioning. i.e. true | false | string | `"false"` | no |
| website | Use bucket as a static website. i.e. true | false | string | `"false"` | no |
| website\_error | Location of Error HTML file. i.e. error.html | string | `"error.html"` | no |
| website\_index | Location of Index HTML file. i.e index.html | string | `"index.html"` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| bucket\_id | The name of the bucket. |
| bucket\_region | The AWS region this bucket resides in. |

