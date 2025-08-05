# Get Service Account Credential from Vault
data "vault_kv_secret_v2" "gcp_sa" {
  mount = "ci-cd-gcp"
  name  = "dev/gcp-sa"
}

# Get IAP Credentials (OAuth2.0) from Vault
data "vault_kv_secret_v2" "iap_creds" {
  mount = "ci-cd-gcp"
  name  = "dev/iap-creds"
}
