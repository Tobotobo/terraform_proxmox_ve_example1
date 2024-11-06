# terraform_proxmox_ve_example1

## 一応動かせるがまだガバガバ

## 概要
* Terraform を使って Proxmox VE に QEMU の VM インスタンスを立ち上げる
* Cloud-init を使う
* proxmox_cloud_init_disk を使う 
* 簡単に環境を量産する

Proxmox Virtual Environment  
https://www.proxmox.com/en/proxmox-virtual-environment/overview  

Terraform  
https://www.terraform.io/  

Terraform provider plugin for Proxmox  
https://github.com/Telmate/terraform-provider-proxmox  

Terraform Registory - Telmate/proxmox  
https://registry.terraform.io/providers/Telmate/proxmox/latest  

Proxmox Provider の使い方  
https://registry.terraform.io/providers/Telmate/proxmox/latest/docs  

Terraform × cloud-init で VM のセットアップをいい感じにする話  
https://speakerdeck.com/yusuke427/terraform-x-cloud-init-de-vm-nosetutoatupuwoiigan-zinisuruhua  

## 利用イメージ
### 共通設定
* common.template.tfvars をコピーし common.tfvars にリネーム
* common.tfvars を適当に設定
* secrets.template.tfvars をコピーし secrets.tfvars にリネーム
* secrets.tfvars を適当に設定

### 環境作成
* enviroments/template/almalinux_8_git_docker_template を enviroments フォルダ内にコピー
* フォルダ名を適当に変更 ※例:pve-vm-100
* フォルダ内の terraform.template.tfvars を terraform.tfvars にリネーム
* terraform.tfvars を設定に設定
* フォルダ内で `terraform init` を実行
* フォルダ内で `terraform plan -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"` を実行
* フォルダ内で `terraform apply -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"` を実行

### 破棄する場合  
* フォルダ内で `terraform destroy -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"` を実行 

## 環境
* Proxmox VE 8.2.2
* Terraform v1.9.8 on windows_amd64
* Terraform provider plugin for Proxmox 3.0.1-rc4

## 前提
* [AlmaLinux 8 の汎用クラウド(Cloud-init)イメージをテンプレートに登録](https://github.com/Tobotobo/proxmox-ve_qemu_almalinux-8/blob/main/docs/001_create_template_almalinux_8_cloud_image.md) が実施済みであること

## 詳細

### 操作対象の Proxmox VE に Terraform 用のユーザーとロールを作成

※`Datastore.Allocate` を追加。cloud-init の config ファイルを local の iso イメージとして作成した際、削除できなくなるため
```
user_pass="terraform"
pveum role add TerraformProv -privs " \
    Datastore.AllocateSpace \
    Datastore.AllocateTemplate \
    Datastore.Audit \
    Datastore.Allocate \
    Pool.Allocate \
    Sys.Audit \
    Sys.Console \
    Sys.Modify \
    VM.Allocate \
    VM.Audit \
    VM.Clone \
    VM.Config.CDROM \
    VM.Config.Cloudinit \
    VM.Config.CPU \
    VM.Config.Disk \
    VM.Config.HWType \
    VM.Config.Memory \
    VM.Config.Network \
    VM.Config.Options \
    VM.Migrate \
    VM.Monitor \
    VM.PowerMgmt \
    SDN.Use \
    "
pveum user add terraform-prov@pve --password ${user_pass}
pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

### provider の proxmox の接続情報を設定　※以下はメンテナンス中
※本来は環境変数などで設定すべきだが今はガバガバ

modules\create_vm\main.tf
```ruby
provider "proxmox" {
  pm_user        = "terraform-prov@pve"
  pm_password    = "terraform"
  pm_api_url     = "http://XXXXX:8006/api2/json"
  pm_tls_insecure = true
}
```

### 環境を作成
※今はガバガバ

#### vm_node を環境に合わせて変更  
environments\pve-vm-001\main.tf  
environments\pve-vm-002\main.tf  
```ruby
    vm_node       = "pve"
```

#### 作成した環境のフォルダに移動

※以下は pve-vm-001 の例
```
cd ./environments/pve-vm-001
```

#### 初期化
```
terraform init
```

#### 適用した際に何が変わるか確認
```
terraform plan
```

#### 問題なければ適用
```
terraform apply
```

#### 破棄する場合
```
terraform destroy
```

## メモ
```
terraform plan -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"
terraform apply -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"
terraform destroy -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"
```

ssh user001@pve-vm-001