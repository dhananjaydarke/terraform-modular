variable "name" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "az_count" {
  description = "Number of Availability Zones to span"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways and private outbound routes"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
