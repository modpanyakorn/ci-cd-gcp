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

variable "domains" {
  description = "List of domains for default service (Terraform needed)"
  type        = list(string)
}

variable "grafana_sub_domain" {
  description = "sub domains for Grafana"
  type        = list(string)
}

variable "prometheus_sub_domain" {
  description = "List of domains for Prometheus"
  type        = list(string)
}

variable "jenkins_sub_domain" {
  description = "List of domains for Jenkins"
  type        = list(string)
}

variable "sonarqube_sub_domain" {
  description = "List of domains for Sonarqube"
  type        = list(string)
}

variable "mongo_express_sub_domain" {
  description = "List of domains for mongo_express"
  type        = list(string)
}

variable "cadvisor_sub_domain" {
  description = "List of domains for cadvisor"
  type        = list(string)
}

