variable "bucket_acl" {
  description = "Bucket ACL. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. For more details https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
  type        = string
  default     = "bucket-owner-full-control"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). Must be globally unique. If changed, forces a new resource."
  type        = string
}

variable "bucket_logging" {
  description = "Enable bucket logging. Will store logs in another existing bucket. You must give the log-delivery group WRITE and READ_ACP permissions to the target bucket. i.e. true | false"
  type        = string
  default     = false
}

variable "bucket_tags" {
  description = "A map of tags to be applied to the Bucket. i.e {Environment='Development'}"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Application environment for which this network is being created. must be one of ['Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test']"
  type        = string
  default     = "Development"
}

variable "force_destroy_bucket" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = string
  default     = false
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = string
  default     = ""
}

variable "lifecycle_enabled" {
  description = "Enable object lifecycle management. i.e. true | false"
  type        = string
  default     = false
}

variable "lifecycle_rule_prefix" {
  description = "Object keyname prefix identifying one or more objects to which the rule applies. Set as an empty string to target the whole bucket."
  type        = string
  default     = ""
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

variable "noncurrent_version_expiration_days" {
  description = "Indicates after how many days we are deleting previous version of objects.  Set to 0 to disable or at least 365 days longer than noncurrent_version_transition_glacier_days. i.e. 0 to disable, 1-999 otherwise"
  type        = string
  default     = 0
}

variable "noncurrent_version_transition_glacier_days" {
  description = "Indicates after how many days we are moving previous versions to Glacier.  Should be 0 to disable or at least 30 days longer than noncurrent_version_transition_ia_days. i.e. 0 to disable, 1-999 otherwise"
  type        = string
  default     = 0
}

variable "noncurrent_version_transition_ia_days" {
  description = "Indicates after how many days we are moving previous version objects to Standard-IA storage. Set to 0 to disable."
  type        = string
  default     = 0
}

variable "object_expiration_days" {
  description = "Indicates after how many days we are deleting current version of objects. Set to 0 to disable or at least 365 days longer than TransitionInDaysGlacier. i.e. 0 to disable, otherwise 1-999"
  type        = string
  default     = 0
}

variable "sse_algorithm" {
  description = "The server-side encryption algorithm to use. Valid values are AES256, aws:kms, and none"
  type        = string
  default     = "AES256"
}

variable "transition_to_glacier_days" {
  description = "Indicates after how many days we are moving current versions to Glacier.  Should be 0 to disable or at least 30 days longer than transition_to_ia_days. i.e. 0 to disable, otherwise 1-999"
  type        = string
  default     = 0
}

variable "transition_to_ia_days" {
  description = "Indicates after how many days we are moving current objects to Standard-IA storage. i.e. 0 to disable, otherwise 1-999"
  type        = string
  default     = 0
}

variable "versioning" {
  description = "Enable bucket versioning. i.e. true | false"
  type        = string
  default     = false
}

variable "website" {
  description = "Use bucket as a static website. i.e. true | false"
  type        = string
  default     = false
}

variable "website_error" {
  description = "Location of Error HTML file. i.e. error.html"
  type        = string
  default     = "error.html"
}

variable "website_index" {
  description = "Location of Index HTML file. i.e index.html"
  type        = string
  default     = "index.html"
}

variable "allowed_origins" {
  description = "(Required) Specifies which origins are allowed."
  type        = list(string)
  default     = []
}

variable "allowed_methods" {
  description = "(Required) Specifies which methods are allowed. Can be GET, PUT, POST, DELETE or HEAD."
  type        = list(string)
  default     = []
}

variable "expose_headers" {
  description = " Specifies expose header in the response."
  type        = list(string)
  default     = []
}

variable "allowed_headers" {
  description = "Specifies which headers are allowed."
  type        = list(string)
  default     = []
}

variable "max_age_seconds" {
  description = "Specifies time in seconds that browser can cache the response for a preflight request."
  type        = string
  default     = "600"
}

