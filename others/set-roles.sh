set -e
set -x

source /root/files/admin-openrc.sh

openstack role add --user admin --project demo admin
