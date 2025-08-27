output "vm_ips" {
  value = {
    nginx_proxy_public  = module.nginx_vm.external_ip
    nginx_proxy_private = module.nginx_vm.internal_ip
    frontend_private    = module.frontend_vm.internal_ip
    backend_private     = module.backend_vm.internal_ip
    db_private          = module.db_vm.internal_ip
    devops_private      = module.devops_vm.internal_ip
    devops_public       = module.devops_vm.external_ip
    load_balance        = google_compute_global_address.devops_lb_static_ip.address
  }
}

# mapping key
locals {
  value = templatefile("../../ansible/templates/hosts.ini.tftpl", {
    project                = var.project_id
    zone                   = var.zone
    nginx_vm_private_ip    = module.nginx_vm.internal_ip
    frontend_vm_private_ip = module.frontend_vm.internal_ip
    backend_vm_private_ip  = module.backend_vm.internal_ip
    db_vm_private_ip       = module.db_vm.internal_ip
    devops_vm_private_ip   = module.devops_vm.internal_ip
    nginx_vm_name          = module.nginx_vm.instance_name
    frontend_vm_name       = module.frontend_vm.instance_name
    backend_vm_name        = module.backend_vm.instance_name
    db_vm_name             = module.db_vm.instance_name
    devops_vm_name         = module.devops_vm.instance_name
  })
}

resource "local_file" "ansible_inventory" {
  filename = "../../ansible/inventory/hosts.ini"
  content  = local.value
}
