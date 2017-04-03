set -e
set -x

#source /root/files/admin-openrc.sh
source /root/files/demo-openrc.sh

nova boot --flavor m1.small --image nginx-ssl --nic net-id=`neutron net-list | grep p2 | awk '{print $2;}'`,v4-fixed-ip=10.0.2.10 nginx1
