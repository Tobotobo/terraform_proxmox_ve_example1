#!/usr/bin/env bash

terraform plan -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"