#!/usr/bin/env bash

set -eu

IMAGE_NAME="ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)"
TMP_NAME="${IMAGE_NAME} [tmp]"
MURANO_NAME="ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)" # Don't change this

packer build -var "image_name=${TMP_NAME}" build.pkr.hcl

echo "--------- image: ${TMP_NAME} -----------"
echo "    Setting Murano title to: ${MURANO_NAME} "
openstack image set --property \
  murano_image_info="{\"title\": \"${MURANO_NAME}\", \"type\": \"linux.ubuntu\"}" \
  "${TMP_NAME}"

# Delete old and rename new
set -x
openstack image delete "$IMAGE_NAME" || true
openstack image set --name "$IMAGE_NAME" "$TMP_NAME"
