#!/usr/bin/env bash

openstack image set --property \
  murano_image_info='{"title": "ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)", "type": "linux.ubuntu"}' \
  "ADACS The Littlest JupyterHub (Ubuntu 20.04 LTS Focal)"
