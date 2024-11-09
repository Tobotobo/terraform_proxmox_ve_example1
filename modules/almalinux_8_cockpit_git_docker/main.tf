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

    timezone: Asia/Tokyo
    locale: ja_JP.utf8
    keyboard:
      layout: jp

    ssh_deletekeys: false # VM作成時に古いホストキーを削除して、新しく生成
    ssh_pwauth: true # パスワード認証を有効化

    users:
      - name: ${var.user_name}
        plain_text_passwd: ${var.user_pass}
        lock_passwd: false
        sudo: ALL=(ALL) NOPASSWD:ALL
        groups: 
          - sudo
          - docker
        shell: /bin/bash

    write_files:
      # Proxmox Console でロケールが適用されない問題への対応
      - path: /etc/profile.d/locale_load.sh
        content: |
          if [ -f /etc/locale.conf ]; then
              source /etc/locale.conf
          fi
        permissions: '0644'

      # 自前の ssh_host_key を適用
      - path: /etc/ssh/ssh_host_ecdsa_key
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_ecdsa_key")}"
        owner: root:ssh_keys
        permissions: '0600'
      - path: /etc/ssh/ssh_host_ecdsa_key.pub
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_ecdsa_key.pub")}"
        owner: root:root
        permissions: '0640'
      - path: /etc/ssh/ssh_host_ed25519_key
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_ed25519_key")}"
        owner: root:ssh_keys
        permissions: '0600'
      - path: /etc/ssh/ssh_host_ed25519_key.pub
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_ed25519_key.pub")}"
        owner: root:root
        permissions: '0640'
      - path: /etc/ssh/ssh_host_rsa_key
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_rsa_key")}"
        owner: root:ssh_keys
        permissions: '0600'
      - path: /etc/ssh/ssh_host_rsa_key.pub
        encoding: base64
        content: "${filebase64("ssh_host_key/ssh_host_rsa_key.pub")}"
        owner: root:root
        permissions: '0640'

      # pve-root-ca で署名したオレオレサーバー証明書(server-cert)を転送
      - path: /var/opt/pve-vm/server-cert/server.crt
        encoding: base64
        content: "${filebase64("server-cert/server.crt")}"
        owner: root:root
        permissions: '0640'
      - path: /var/opt/pve-vm/server-cert/server.csr
        encoding: base64
        content: "${filebase64("server-cert/server.csr")}"
        owner: root:root
        permissions: '0640'
      - path: /var/opt/pve-vm/server-cert/server.key
        encoding: base64
        content: "${filebase64("server-cert/server.key")}"
        owner: root:root
        permissions: '0600'

    bootcmd:
      - dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
      - dnf install -y epel-release

    package_update: true
    packages:
      - glibc-langpack-ja
      - langpacks-ja
      - cockpit
      - avahi
      - nss-mdns
      - nano
      - git
      - docker-ce
      - docker-ce-cli
      - containerd.io

    runcmd:
      # IPv6 無効化
      - echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
      - echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
      - sysctl -p
      
      # Cockpit にオレオレサーバー証明書を適用
      - rm -f /etc/cockpit/ws-certs.d/*
      - cp /var/opt/pve-vm/server-cert/* /etc/cockpit/ws-certs.d/
      
      # サービス起動 & 自動起動を有効化
      - systemctl enable --now cockpit.socket
      - systemctl enable --now avahi-daemon
      - systemctl enable --now docker
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
