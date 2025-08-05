output "subnet_names" {
  value = { for s in google_compute_subnetwork.this : s.name => s.name }
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}
