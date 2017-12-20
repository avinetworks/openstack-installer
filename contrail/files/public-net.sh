set -e
set -x

interface=vhost0
myip=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); print a[2];}'`
my_ip_pref=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); split(a[2], b, "."); printf("%s.%s.%s.", b[1], b[2], b[3]);}'`

# for floating IP and external connectivity
# choose a small pool from the subnet from eth0
POOL_START=${my_ip_pref}161
POOL_END=${my_ip_pref}190
GW=${my_ip_pref}1
CIDR=${my_ip_pref}0/24

echo 1 > /proc/sys/net/ipv4/conf/vhost0/proxy_arp
echo 1 > /proc/sys/net/ipv4/conf/vgw1/proxy_arp

export OS_USERNAME=admin
export OS_AUTH_URL=http://localhost:5000/v2.0
export OS_PASSWORD=avi123
export OS_TENANT_NAME=admin

neutron net-create public --shared --router:external True
neutron subnet-create --gateway $GW --allocation-pool start=$POOL_START,end=$POOL_END public $CIDR

