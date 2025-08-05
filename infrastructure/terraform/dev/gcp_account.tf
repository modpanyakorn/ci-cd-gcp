# Define Service Account for VMs
resource "google_service_account" "vm_service_account" {
  project      = var.project_id
  account_id   = "ci-cd-gcp-vm-sa"
  display_name = "CI/CD GCP project VM Service Account"
  description  = "Service account for VMs"
}

# Grant Permisson to Service Account
resource "google_project_iam_member" "vm_service_account_roles" {
  for_each = toset([
    "roles/logging.logWriter",       # Writing Log
    "roles/monitoring.metricWriter", # Writing Metrics
    "roles/storage.objectViewer",    # Read Cloud Storage
    "roles/storage.objectAdmin"      # Writing GCS
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vm_service_account.email}"
}

# Grant Permisson to Memebers
resource "google_service_account_iam_member" "service_account_user_role" {
  for_each           = toset(var.members)
  service_account_id = google_service_account.vm_service_account.name
  role               = "roles/iam.serviceAccountUser" # Members impersonate VMs Service Account
  member             = "user:${each.value}"
}

# Grant Permission to Members
resource "google_project_iam_member" "iap_tunnel_access" {
  for_each = toset(var.members)
  project  = var.project_id
  role     = "roles/iap.tunnelResourceAccessor" # IAP Tunneling Member can access VM via SSH
  member   = "user:${each.value}"
}
