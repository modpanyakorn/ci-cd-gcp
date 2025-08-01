output "internal_ip" {
  value = google_compute_instance.this.network_interface[0].network_ip
}

output "external_ip" {
  value = length(google_compute_instance.this.network_interface[0].access_config) > 0 ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : ""
}

output "instance_name" {
  value = google_compute_instance.this.name
}

output "machine_type" {
  value = google_compute_instance.this.machine_type
}
