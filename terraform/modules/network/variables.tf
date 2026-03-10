variable "environment" {
  description = "Environment name (uat/prod)"
  type        = string
}

variable "vpc_name" {
  description = "Base name for VPC"
  type        = string
  default     = "instahelper-vpc"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}
