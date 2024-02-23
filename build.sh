#!/bin/bash -eu
DEFAULT_IMAGE_NAME="ADACS The Littlest JupyterHub (Ubuntu 22.04 LTS Jammy)"

# If provided, first positional argument will be used as the image name
IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}
TMP_NAME="${IMAGE_NAME} [tmp]"

echo "---> Building image: $IMAGE_NAME"
packer build -var "image_name=${TMP_NAME}" build.pkr.hcl

echo "---> Deleting old image and renaming the new one"
set -x
openstack image delete "$IMAGE_NAME" || true
openstack image set --name "$IMAGE_NAME" "$TMP_NAME"
