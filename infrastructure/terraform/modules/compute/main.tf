# Static IP
resource "google_compute_address" "static_ip" {

  count = var.assign_static_public_ip ? 1 : 0

  project = var.project_id

  name = "${var.name}-static-ip"

}

# VMs template
resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = var.allow_stopping_for_update
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = var.disk_type
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    dynamic "access_config" {
      for_each = var.assign_public_ip ? [1] : []
      content {
        nat_ip = var.assign_static_public_ip ? google_compute_address.static_ip[0].address : null
      }
    }
  }

  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  metadata = length(var.startup_script) > 0 ? {
    startup-script = var.startup_script
    enable-oslogin = var.enable_os_login
  } : {}

  tags = var.tags

  lifecycle {
    ignore_changes = [
      metadata["ssh-keys"]
    ]
  }
}
