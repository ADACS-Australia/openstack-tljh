#!/bin/bash -xeu
# Script update server

systemctl stop unattended-upgrades || true
systemctl disable unattended-upgrades || true
while ! apt-get remove -y unattended-upgrades; do sleep 1; done
apt-get purge -y unattended-upgrades
apt-get update -y
