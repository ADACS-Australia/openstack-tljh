#!/bin/bash -u
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: please run as root"
  exit 1
fi

errcode=0

for DEV in $(ls /dev/vd[a-z]1); do
  echo "---> Enabling quotas on: $DEV"
  mount -o remount "$DEV"   || {((++errcode)) && continue;}
  quotaoff "$DEV"           || {((++errcode)) && continue;}
  quotacheck -cvugm "$DEV"  || {((++errcode)) && continue;}
  quotaon -vug "$DEV"       || {((++errcode)) && continue;}
  echo
done

if [ "$errcode" != 0 ]; then
  echo 'ERROR: You may need to reboot the system to load the quota kernel modules ("sudo reboot")'
fi

exit $errcode
