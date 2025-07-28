# # data.tf ในแต่ละ env
# data "google_compute_image" "debian_latest" {
#   family  = "debian-11"
#   project = "debian-cloud"
# }

# data "vault_kv_secret_v2" "gcp_sa" {
#   mount = "secret"
#   name  = "dev/gcp-service-account"
# }

# output "gcp_sa_key" {
#   value = data.vault_kv_secret_v2.gcp_sa.data["key"]
# }


# locals {
#   latest_debian = data.google_compute_image.debian_latest.self_link
# }

# data "google_compute_image" "debian_latest" {
#   family  = "debian-11"
#   project = "debian-cloud"
# }
