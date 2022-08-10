#!/usr/bin/env bash

set -eu

IMAGE_NAME="ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal) [dev]"
MURANO_NAME="ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)" # Don't change this

packer build -var "image_name=${IMAGE_NAME}" packer.json

openstack image set --property \
  murano_image_info="{'title': '${MURANO_NAME}', 'type': 'linux.ubuntu'}" \
  "${IMAGE_NAME}"
