resource "proxmox_cloud_init_disk" "ci" {
  name     = "${var.vm_name}"
  pve_node = "${var.vm_node}"
  storage  = "local"

  meta_data = yamlencode({
    instance_id = "${var.vm_name}"
  })

  user_data = <<-EOF
    #cloud-config
    hostname: ${var.vm_name}
    fqdn: ${var.vm_name}.local

    bootcmd:
      - dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    package_update: true
    packages:
      - glibc-langpack-ja
      - langpacks-ja
      - avahi
      - nano
      - git
      - docker-ce
      - docker-ce-cli
      - containerd.io

    timezone: Asia/Tokyo
    locale: ja_JP.utf8
    keyboard:
      layout: jp

    write_files:
      - path: /etc/profile.d/locale_load.sh
        content: |
          if [ -f /etc/locale.conf ]; then
              source /etc/locale.conf
          fi
        permissions: '0644'

    ssh_pwauth: true

    users:
      - name: ${var.user_name}
        plain_text_passwd: ${var.user_pass}
        lock_passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: 
          - sudo
          - docker
        shell: /bin/bash

    runcmd:
      - echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
      - echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
      - sysctl -p
      - systemctl start avahi-daemon
      - systemctl enable avahi-daemon
      - systemctl start docker
      - systemctl enable docker
  EOF
}

resource "proxmox_vm_qemu" "vm" {
  name        = "${var.vm_name}"
  target_node = "${var.vm_node}"
  clone       = "almalinux-8-template"
  cores       = "${var.vm_cores}"
  memory      = "${var.vm_memory}"
  os_type     = "cloud-init"
  boot        = "order=scsi0"
  scsihw      = "virtio-scsi-single"
  agent = 1

  serial {
    id      = 0
    type    = "socket"
  }

  vga {
    type    = "serial0"
  }

  disks {
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "${var.vm_disk_size}" 
        }
      }
    }
    ide {
      ide2 {
        cdrom {
          iso = proxmox_cloud_init_disk.ci.id
        }
      }
    }
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }
  ipconfig0 = "${var.vm_ipconfig0}"
}
