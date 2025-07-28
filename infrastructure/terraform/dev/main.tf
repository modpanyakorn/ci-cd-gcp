module "network" {
  source   = "./modules/network"
  region   = var.region
  vpc_name = "dev-vpc"
  subnets = {
    public-subnet   = { cidr = "10.10.0.0/24" },
    frontend-subnet = { cidr = "10.10.1.0/24" },
    backend-subnet  = { cidr = "10.10.2.0/24" },
    db-subnet       = { cidr = "10.10.3.0/24" },
    devops-subnet   = { cidr = "10.10.4.0/24" }
  }
}

# locals {
#   image_debian = "debian-cloud/debian-11"
# }

# HAProxy (Public)
module "haproxy_vm" {
  source       = "./modules/compute"
  name         = "haproxy-dev"
  machine_type = "e2-small"
  zone         = var.zone
  image        = var.image_ubuntu
  subnetwork   = module.network.subnet_names["public-subnet"]
  tags         = ["haproxy", "public"]
}

# Frontend
module "frontend_vm" {
  source       = "./modules/compute"
  name         = "frontend-dev"
  machine_type = "e2-medium"
  zone         = var.zone
  image        = var.image_ubuntu
  subnetwork   = module.network.subnet_names["frontend-subnet"]
  tags         = ["frontend"]
}

# Backend
module "backend_vm" {
  source       = "./modules/compute"
  name         = "backend-dev"
  machine_type = "e2-medium"
  zone         = var.zone
  image        = var.image_ubuntu
  subnetwork   = module.network.subnet_names["backend-subnet"]
  tags         = ["backend"]
}

# MongoDB
module "db_vm" {
  source       = "./modules/compute"
  name         = "mongo-dev"
  machine_type = "e2-small"
  zone         = var.zone
  image        = var.image_ubuntu
  subnetwork   = module.network.subnet_names["db-subnet"]
  tags         = ["db"]
}

# devops vm
module "devops_vm" {
  source       = "./modules/compute"
  name         = "devops-dev"
  machine_type = "e2-medium"
  zone         = var.zone
  image        = var.image_ubuntu
  subnetwork   = module.network.subnet_names["devops-subnet"]
  tags         = ["devops"]
}
