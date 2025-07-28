variable "vpc_name" {}
variable "region" {}
variable "subnets" { # map of { cidr = string }
  type = map(object({ cidr = string }))
}
variable "create_nat" { default = true }
