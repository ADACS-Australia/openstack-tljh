#!/bin/bash -u
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: please run as root"
  exit 1
fi

errcode=0

echo "---> Enabling quotas on: $(echo /dev/vd[a-z]1)"
for DEV in $(ls /dev/vd[a-z]1); do
  mount -o remount "$DEV" || ((++errcode))
done

quotaoff -a        || ((++errcode))
quotacheck -acvugm || ((++errcode))
quotaon -avug      || ((++errcode))

if [ "$errcode" != 0 ]; then
  echo
  echo 'ERROR: You may need to reboot the system to load the quota kernel modules ("sudo reboot")'
else
  echo "<--- Finished enabling quotas"
fi
