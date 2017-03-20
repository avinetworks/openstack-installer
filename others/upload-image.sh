set -e
set -x

# upload cirros image to glance in shared
source /root/files/admin-openrc.sh

glance image-create --name cirros-web --disk-format qcow2 --container-format bare --file cirros-web.qcow2 --visibility public --progress
