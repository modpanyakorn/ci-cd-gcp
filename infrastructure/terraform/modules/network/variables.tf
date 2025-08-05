variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}
variable "region" {
  description = "GCP region for resources"
  type        = string
}
variable "subnets" { # map of { cidr = string }
  type = map(object({ cidr = string }))
}
variable "create_nat" { default = true }
