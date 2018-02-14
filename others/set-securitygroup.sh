set -e
set -x

#source /root/files/admin-openrc.sh
source /root/files/demo-openrc.sh

openstack security group rule create default --protocol icmpv6 --ingress --remote-ip 0::/0
openstack security group rule create default --protocol icmp --ingress --remote-ip 0.0.0.0/0

openstack security group rule create default --protocol tcp --dst-port 1:65535 --ingress --ethertype IPv4 --remote-ip 0.0.0.0/0
openstack security group rule create default --protocol tcp --dst-port 1:65535 --ingress --ethertype IPv6 --remote-ip 0::/0

openstack security group rule create default --protocol udp --dst-port 1:65535 --ingress --ethertype IPv4 --remote-ip 0.0.0.0/0
openstack security group rule create default --protocol udp --dst-port 1:65535 --ingress --ethertype IPv6 --remote-ip 0::/0
