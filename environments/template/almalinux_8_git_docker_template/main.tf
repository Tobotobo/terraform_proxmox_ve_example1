module "almalinux_8_git_docker_vm" {
    source = "../../modules/almalinux_8_git_docker"
    vm_node       = var.vm_node
    vm_name       = var.vm_name
    vm_cores      = var.vm_cores
    vm_memory     = var.vm_memory
    vm_disk_size  = var.vm_disk_size
    vm_ipconfig0 = var.vm_ipconfig0
    user_name     = var.user_name
    user_pass     = var.user_pass
    pm_user = var.pm_user
    pm_password = var.pm_password
    pm_api_url = var.pm_api_url
}