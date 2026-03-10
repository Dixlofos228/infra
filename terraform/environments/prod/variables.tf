variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name (uat/prod)"
  type        = string
  default     = "uat"
}

variable "machine_type_app" {
  description = "Machine type for app instances"
  type        = string
  default     = "e2-small"
}

variable "machine_type_monitoring" {
  description = "Machine type for monitoring"
  type        = string
  default     = "e2-small"
}

variable "app_instance_count" {
  description = "Number of app instances"
  type        = number
  default     = 1
}

variable "vm_image" {
  description = "VM image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}
