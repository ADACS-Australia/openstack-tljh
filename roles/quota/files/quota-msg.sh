if groups | grep -q jupyterhub-admins && quotaon -p -a | grep -q "is off"; then
cat << EOF
Warning:

$(quotaon -p -a | grep "is off")

You may need to reboot the system to enable the quota kernel modules.
("sudo reboot")

EOF
fi
