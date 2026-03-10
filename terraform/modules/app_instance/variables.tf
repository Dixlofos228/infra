variable "environment" {
  description = "Environment name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for instances"
  type        = string
  default     = "e2-small"
}

variable "zone" {
  description = "GCP zone"
  type        = string
}

variable "subnet" {
  description = "Subnet self link"
  type        = string
}

variable "vm_image" {
  description = "VM image"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "instance_count" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags"
  type        = list(string)
  default     = []
}
