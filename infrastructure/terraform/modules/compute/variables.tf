variable "name" {}
variable "machine_type" {}
variable "zone" {}
variable "image" {}
variable "subnetwork" {}
variable "tags" { default = [] }
variable "startup_script" { default = "" } # for dynamic startup scripts
