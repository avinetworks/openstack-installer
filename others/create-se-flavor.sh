set -e
set -x

source /root/files/admin-openrc.sh

openstack flavor create m1.vm --id auto --public --ram 1024 --disk 10 --vcpus 1
openstack flavor create m1.se --id auto --public --ram 2048 --disk 15 --vcpus 1
