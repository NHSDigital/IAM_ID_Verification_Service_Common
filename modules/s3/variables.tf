variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "enable_bucket_notifications" {
  description = "Enable bucket notifications"
  type        = bool
  default     = false
}

variable "enable_logging" {
  description = "Enable logging for the S3 bucket"
  type        = bool
  default     = false
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "logging_bucket" {
  description = "The name of the bucket to store logs"
  type        = string
}

variable "policy_document" {
  description = "Additional s3 policy document to attach to the S3 bucket"
  type        = string
  default     = "{}"
}

variable "s3_kms_key_arn" {
  description = "The ARN of the KMS key to use for S3 server-side encryption"
  type        = string
}
