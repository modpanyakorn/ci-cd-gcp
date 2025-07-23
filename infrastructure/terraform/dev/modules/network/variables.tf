variable "vpc_name" {}
variable "region" {}
variable "subnets" {
  type = map(object({ cidr = string }))
}
