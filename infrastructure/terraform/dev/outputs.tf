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
    project                 = var.project_id
    zone                    = var.zone
    nginx_dev_private_ip    = module.nginx_vm.internal_ip
    frontend_dev_private_ip = module.frontend_vm.internal_ip
    backend_dev_private_ip  = module.backend_vm.internal_ip
    db_dev_private_ip       = module.db_vm.internal_ip
    devops_dev_private_ip   = module.devops_vm.internal_ip
  })
}

resource "local_file" "ansible_inventory" {
  filename = "../../ansible/inventory/hosts.ini"
  content  = local.value
}
