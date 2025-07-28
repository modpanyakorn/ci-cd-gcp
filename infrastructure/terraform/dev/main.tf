# provider "google" {
#   project = var.project_id
#   region  = var.region
#   zone    = var.zone
# }

module "network" {
  source   = "./modules/network"
  region   = var.region
  vpc_name = "dev-vpc"
  subnets = {
    public-subnet = { cidr = "10.10.0.0/24" }
    app-subnet    = { cidr = "10.10.1.0/24" }
    db-subnet     = { cidr = "10.10.2.0/24" }
    devops-subnet = { cidr = "10.10.3.0/24" }
  }
}

module "frontend_vm" {
  source       = "./modules/compute"
  name         = "frontend-dev"
  machine_type = "e2-medium"
  zone         = var.zone
  image        = "debian-cloud/debian-11"
  subnetwork   = module.network.subnet_names["app-subnet"]
  tags         = ["frontend"]
}
