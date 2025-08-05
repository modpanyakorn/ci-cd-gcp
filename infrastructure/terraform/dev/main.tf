# Define VPC, Subnets
module "network" {
  source   = "../modules/network"
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

# HAProxy (Public)
module "haproxy_vm" {
  project_id              = var.project_id
  service_account         = google_service_account.vm_service_account.email
  source                  = "../modules/compute"
  name                    = "haproxy-dev"
  machine_type            = "e2-micro"
  zone                    = var.zone
  image                   = var.image
  disk_size               = 10
  disk_type               = "pd-balanced"
  subnetwork              = module.network.subnet_names["public-subnet"]
  assign_public_ip        = true # need public ip
  assign_static_public_ip = true # public ip are static even restart vm
  tags                    = ["public", "haproxy"]
}

# Frontend
module "frontend_vm" {
  project_id              = var.project_id
  service_account         = google_service_account.vm_service_account.email
  source                  = "../modules/compute"
  name                    = "frontend-dev"
  machine_type            = "e2-micro"
  zone                    = var.zone
  image                   = var.image
  disk_size               = 10
  disk_type               = "pd-balanced"
  subnetwork              = module.network.subnet_names["frontend-subnet"]
  assign_public_ip        = false
  assign_static_public_ip = false
  tags                    = ["private", "frontend"]
}

# Backend
module "backend_vm" {
  project_id              = var.project_id
  service_account         = google_service_account.vm_service_account.email
  source                  = "../modules/compute"
  name                    = "backend-dev"
  machine_type            = "e2-micro"
  zone                    = var.zone
  image                   = var.image
  disk_size               = 10
  disk_type               = "pd-balanced"
  subnetwork              = module.network.subnet_names["backend-subnet"]
  assign_public_ip        = false
  assign_static_public_ip = false
  tags                    = ["private", "backend"]
}

# DB
module "db_vm" {
  project_id              = var.project_id
  service_account         = google_service_account.vm_service_account.email
  source                  = "../modules/compute"
  name                    = "db-dev"
  machine_type            = "e2-micro"
  zone                    = var.zone
  image                   = var.image
  disk_size               = 10
  disk_type               = "pd-balanced"
  subnetwork              = module.network.subnet_names["db-subnet"]
  assign_public_ip        = false
  assign_static_public_ip = false
  tags                    = ["private", "db"]
}

# DevOps
module "devops_vm" {
  project_id              = var.project_id
  service_account         = google_service_account.vm_service_account.email
  source                  = "../modules/compute"
  name                    = "devops-dev"
  machine_type            = "e2-small"
  zone                    = var.zone
  image                   = var.image
  disk_size               = 16
  disk_type               = "pd-balanced"
  subnetwork              = module.network.subnet_names["devops-subnet"]
  assign_public_ip        = false
  assign_static_public_ip = false
  tags                    = ["devops"]
}
