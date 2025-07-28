variable "name" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "subnetwork" {}
variable "tags" { default = [] }
variable "startup_script" { default = "" } # for dynamic startup scripts
variable "service_account" { default = "" }
variable "assign_public_ip" { default = true }
variable "disk_size" { default = 20 }
variable "disk_type" { default = "pd-standard" }
