set -e
set -x

#source /root/files/admin-openrc.sh
source /root/files/demo-openrc.sh

nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova secgroup-add-rule default tcp 80 80 0.0.0.0/0
nova secgroup-add-rule default tcp 443 443 0.0.0.0/0

nova secgroup-add-rule default icmp -1 -1 0::/0
nova secgroup-add-rule default tcp 22 22 0::/0
nova secgroup-add-rule default tcp 80 80 0::/0
nova secgroup-add-rule default tcp 443 443 0::/0
