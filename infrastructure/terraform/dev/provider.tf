terraform {
  required_version = ">=1.12.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.46.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.1.0"
    }
  }
}

provider "vault" {
  address = var.vault_address # read environment variable
  token   = var.vault_token   # read environment variable
}

provider "google" {
  credentials = data.vault_kv_secret_v2.gcp_sa.data["key"] # read from vault server
  project     = var.project_id                             # read .tfvars
  region      = var.region                                 # read .tfvars
  zone        = var.zone                                   # read .tfvars
}
