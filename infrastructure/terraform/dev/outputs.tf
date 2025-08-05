output "vm_ips" {
  value = {
    haproxy_public   = module.haproxy_vm.external_ip
    haproxy_private  = module.haproxy_vm.internal_ip
    frontend_public  = module.frontend_vm.external_ip
    frontend_private = module.frontend_vm.internal_ip
    backend_public   = module.backend_vm.external_ip
    backend_private  = module.backend_vm.internal_ip
    db_private       = module.db_vm.internal_ip
    devops_public    = module.devops_vm.external_ip
    devops_private   = module.devops_vm.internal_ip
  }
}

# Load Balancer
output "devops_lb_ip" {
  description = "The public IP address of the DevOps IAP Load Balancer"
  value       = google_compute_global_address.devops_lb_static_ip.address
}
