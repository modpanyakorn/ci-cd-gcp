resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk { initialize_params { image = var.image } }

  network_interface {
    subnetwork   = var.subnetwork
    access_config {}                        # public IP
  }

  metadata = length(var.startup_script) > 0 ? {
  startup-script = var.startup_script
  } : {}

  tags = var.tags
}

