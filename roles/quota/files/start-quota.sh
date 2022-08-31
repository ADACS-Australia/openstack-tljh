#!/bin/bash -u
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: please run as root"
  exit 1
fi

H="${1:-}"

if [ "$H" == "-h" ] || [ "$H" == "--help" ];then
cat << EOF
Usage: start-quota [-h] [--help] [<quota>]

Start the quota service on all devices (/dev/vdb[a-z]1) and set quota for all new users.

Positional arguments:
  quota               Quota to set for all new users. Interpreted as multiples
                      of kibibyte (1024 bytes) blocks by default.
                      Symbols K, M, G, and T can be appended to numeric value
                      to express kibibytes, mebibytes, gibibytes, and tebibytes.
                      [Default: 2G]
EOF
  exit 0
fi

DEFAULT_QUOTA="${1:-2G}"
errcode=0

for DEV in $(ls /dev/vd[a-z]1); do
  echo "---> Enabling quotas on: $DEV"
  mount -o remount "$DEV"                                              || {((++errcode)) && continue;}
  quotaoff "$DEV"                                                      || {((++errcode)) && continue;}
  quotacheck -cvugm "$DEV"                                             || {((++errcode)) && continue;}
  quotaon -vug "$DEV"                                                  || {((++errcode)) && continue;}
  setquota -u quotauser "$DEFAULT_QUOTA" "$DEFAULT_QUOTA" 0 0 ""$DEV"" || {((++errcode)) && continue;}
  echo
done

if [ "$errcode" != 0 ]; then
  echo 'ERROR: You may need to reboot the system to load the quota kernel modules ("sudo reboot")'
fi

exit $errcode
