variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
}
variable "zone" {
  description = "GCP zone for resources"
}
variable "image" {
  description = "Ubuntu image for VM instances"
}
variable "vault_address" {
  description = "location of the Vault server"
}

variable "vault_token" {
  description = "token for accessing Vault"
}

variable "members" {
  description = "list of team members' emails for IAM roles"
  type        = list(string)
}
