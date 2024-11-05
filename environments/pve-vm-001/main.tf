module "create_vm" {
    source = "../../modules/create_vm"
    
    vm_node       = "pve"
    vm_name       = "pve-vm-001"
    vm_cores      = "2"
    vm_memory     = "2048"
    vm_disk_size  = "20G"
    vm_ip_address = "dhcp"
    user_name     = "user001"
    user_pass     = "user001"
}