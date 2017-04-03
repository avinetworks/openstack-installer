set -e
set -x

source /root/files/admin-openrc.sh

openstack flavor create m1.se --id auto --public --ram 1024 --disk 10 --vcpus 1
