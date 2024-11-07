@echo off

terraform destroy -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"