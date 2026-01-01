variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
}

variable "default_root_object" {
  description = "Default root object for CloudFront"
  type        = string
  default     = "index.html"
}

variable "api_origin_domain_name" {
  description = "API origin domain name for CloudFront (optional)"
  type        = string
  default     = ""
}

variable "api_origin_id" {
  description = "Origin ID for the API origin"
  type        = string
  default     = "api-origin"
}

variable "api_origin_path" {
  description = "Origin path for the API origin"
  type        = string
  default     = ""
}

variable "api_origin_protocol_policy" {
  description = "Protocol policy for the API origin"
  type        = string
  default     = "https-only"
}

variable "api_cache_path_pattern" {
  description = "Path pattern for API cache behavior"
  type        = string
  default     = "/api/*"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront (optional)"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Alternate domain names for CloudFront"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
