set -e
set -x

# needed to create with admin login as Ocata policies don't allow users to create ports with specific IP addresses
source /root/files/admin-openrc.sh
#source /root/files/demo-openrc.sh
export OS_PROJECT_NAME=demo

nova boot --flavor m1.se --image nginx-ssl --nic net-id=`neutron net-list | grep p2 | awk '{print $2;}'`,v4-fixed-ip=10.0.2.10 nginx1
