variable "name" {
  description = "Name of the VM instance"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
}

variable "zone" {
  description = "GCP zone for the VM instance"
  type        = string
}

variable "image" {
  description = "Image to use for the VM instance"
  type        = string
}

variable "subnetwork" {
  description = "Subnetwork to attach the VM instance to"
  type        = string
}

variable "tags" {
  description = "Network tags to apply to the VM instance"
  type        = list(string)
}

variable "service_account" {
  description = "Service account email to attach to the VM instance"
  type        = string
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to the VM instance"
  type        = bool
}

variable "assign_static_public_ip" {
  description = "Assign Static Public IP"
  type        = bool
}

variable "disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
}

variable "disk_type" {
  description = "Type of the boot disk"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "allow_stopping_for_update" {
  description = "Stop VM and configure without recrate"
  type        = bool
}

variable "enable_os_login" {
  description = "Enable OS login members can use ssh to access VMs"
  type        = bool
}

variable "startup_script" {
  description = "Startup script to run on VM instance creation"
  type        = string
}
