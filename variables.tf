variable "bucket_logging" {
  description = "Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ_ACP permissions to the target bucket. i.e. true | false"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Block various forms of public access on a per bucket level"
  type        = bool
  default     = false
}

variable "block_public_access_acl" {
  description = "Related to block_public_access. PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL."
  type        = bool
  default     = true
}

variable "block_public_access_ignore_acl" {
  description = "Related to block_public_access. Ignore public ACLs on this bucket and any objects that it contains."
  type        = bool
  default     = true
}

variable "block_public_access_policy" {
  description = "Related to block_public_access. Reject calls to PUT Bucket policy if the specified bucket policy allows public access."
  type        = bool
  default     = true
}

variable "block_public_access_restrict_bucket" {
  description = "Related to block_public_access. Only the bucket owner and AWS Services can access this buckets if it has a public policy."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test']"
  type        = string
  default     = "Development"
}

variable "force_destroy_bucket" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "lifecycle_enabled" {
  description = "Enable object lifecycle management. i.e. true | false"
  type        = bool
  default     = false
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "intelligent_tiering" {
  description = "Map containing intelligent tiering configuration."
  type        = any
  default     = {}
}

variable "metric_configuration" {
  description = "Map containing bucket metric configuration."
  type        = any
  default     = []
}

variable "logging_bucket_name" {
  description = "Name of the existing bucket where the logs will be stored."
  type        = string
  default     = ""
}

variable "logging_bucket_prefix" {
  description = "Prefix for all log object keys. i.e. logs/"
  type        = string
  default     = ""
}

variable "name" {
  description = "The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). Must be globally unique. If changed, forces a new resource."
  type        = string
}

variable "object_expiration_days" {
  description = "Indicates after how many days we are deleting current version of objects. Set to 0 to disable or at least 365 days longer than TransitionInDaysGlacier. i.e. 0 to disable, otherwise 1-999"
  type        = number
  default     = 0
}

variable "object_lock_enabled" {
  description = "Indicates whether this bucket has an Object Lock configuration enabled. Disabled by default. You can only enable S3 Object Lock for new buckets. If you need to turn on S3 Object Lock for an existing bucket, please contact AWS Support."
  type        = bool
  default     = false
}

variable "object_lock_token" {
  description = "A token to allow Object Lock to be enabled for an existing bucket. You must contact AWS support for the bucket's 'Object Lock token'. The token is generated in the back-end when versioning is enabled on a bucket."
  type        = string
  default     = null
}

variable "object_lock_mode" {
  description = "The default Object Lock retention mode you want to apply to new objects placed in this bucket. Valid values are GOVERNANCE and COMPLIANCE. Default is GOVERNANCE (allows administrative override)."
  type        = string
  default     = "GOVERNANCE"
}

variable "object_lock_retention_days" {
  description = "The retention of the object lock in days. Either days or years must be specified, but not both."
  type        = number
  default     = null
}

variable "object_lock_retention_years" {
  description = "The retention of the object lock in years. Either days or years must be specified, but not both."
  type        = number
  default     = null
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256, aws:kms, and none"
  type        = string
  default     = "AES256"
}

variable "kms_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Whether or not to use Amazon S3 Bucket Keys for SSE-KMS."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to be applied to the Bucket. i.e {Environment='Development'}"
  type        = map(string)
  default     = {}
}

variable "versioning" {
  description = "Enable bucket versioning."
  type        = bool
  default     = false
}

variable "mfa_delete" {
  description = "Specifies whether MFA delete is enabled in the bucket versioning configuration"
  type        = bool
  default     = false
}

variable "website" {
  description = "Use bucket as a static website. i.e. true | false"
  type        = bool
  default     = false
}

variable "website_config" {
  description = "Map containing static web-site hosting or redirect configuration."
  type        = any # map(string)
  default     = {}
}

variable "cors" {
  description = "Enable CORS Rules. Rules must be defined in the variable cors_rules"
  type        = bool
  default     = false
}

variable "cors_rule" {
  description = "List of maps containing rules for Cross-Origin Resource Sharing."
  type        = any
  default     = []
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner"
  type        = string
  default     = null
}

variable "enable_intelligent_tiering" {
  description = "Enable intelligent tiering"
  type        = bool
  default     = false
}

variable "enable_bucket_metrics" {
  description = "Enable bucket metrics"
  type        = bool
  default     = false
}

variable "owner" {
  description = "Bucket owner's display name and ID. Conflicts with `acl`"
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "(Optional) The canned ACL to apply. Conflicts with `grant`"
  type        = string
  default     = null
}

variable "grant" {
  description = "An ACL policy grant. Conflicts with `acl`"
  type        = any
  default     = []
}

variable "control_object_ownership" {
  description = "Whether to manage S3 Bucket Ownership Controls on this bucket."
  type        = bool
  default     = false
}

variable "object_ownership" {
  description = "Object ownership. Valid values: BucketOwnerEnforced, BucketOwnerPreferred or ObjectWriter. 'BucketOwnerEnforced': ACLs are disabled, and the bucket owner automatically owns and has full control over every object in the bucket. 'BucketOwnerPreferred': Objects uploaded to the bucket change ownership to the bucket owner if the objects are uploaded with the bucket-owner-full-control canned ACL. 'ObjectWriter': The uploading account will own the object if the object is uploaded with the bucket-owner-full-control canned ACL."
  type        = string
  default     = "ObjectWriter"
}
