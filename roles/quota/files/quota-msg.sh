if [ "$(groups | grep jupyterhub-admins)" != "" ]; then
  list=

  for device in $(ls /dev/vd[a-z]1)
    if [ "$(quotaon -p $device | grep 'user quota' | grep 'is on')" == "" ]; then
      list+="${device} "
    fi
  done

  if [ ! -z "$list" ]; then
cat << EOF
Disk quotas are currently off for the following devices: $list

To turn them on use "sudo start-quota".

Note: you may need to reboot the system first to enable the quota
kernel modules (use "sudo reboot").

EOF
  fi

  unset list

fi
