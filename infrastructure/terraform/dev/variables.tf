variable "project_id" {}
variable "region" { default = "asia-southeast1" }
variable "zone" { default = "asia-southeast1-a" }
variable "image_ubuntu" { default = "ubuntu-os-cloud/ubuntu-2404-lts" }
variable "vault_address" {
  description = "location of the Vault server"
}

variable "vault_token" {
  description = "token for accessing Vault"
}
