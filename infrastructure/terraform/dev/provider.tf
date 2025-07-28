terraform {
  required_providers {
    google = { source = "hashicorp/google" }
    vault  = { source = "hashicorp/vault" }
  }
}

provider "vault" {
  address = var.vault_address # ex. https://vault.example.com
  token   = var.vault_token
}

# ดึง Service‑Account JSON จาก Vault KV v2
data "vault_kv_secret_v2" "gcp_sa" {
  mount = "secret"
  name  = "dev/gcp-sa"
}

provider "google" {
  credentials = data.vault_kv_secret_v2.gcp_sa.data["key"]
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
