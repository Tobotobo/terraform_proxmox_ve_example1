#!/usr/bin/env bash

terraform apply -var-file="../../common.tfvars" -var-file="../../secrets.tfvars"