#!/usr/bin/env bash

terraform destroy -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"