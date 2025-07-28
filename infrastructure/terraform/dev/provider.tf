provider "vault" {
  address = var.vault_addr
}

data "vault_generic_secret" "gcp_creds" {
  path = "gcp/static-account/my-dev-sa"
}

provider "google" {
  credentials = data.vault_generic_secret.gcp_creds.data["key"]
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}
