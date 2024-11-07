@echo off

terraform apply -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"