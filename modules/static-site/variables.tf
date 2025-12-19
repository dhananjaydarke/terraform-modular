variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

