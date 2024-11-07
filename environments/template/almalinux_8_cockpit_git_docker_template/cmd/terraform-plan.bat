@echo off

terraform plan -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"