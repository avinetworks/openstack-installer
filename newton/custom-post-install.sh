set -e
set -x

# get IP of eth1
# use it to populate pool start, end, gw, cidr
interface=eth1
my_ip_pref=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); split(a[2], b, "."); printf("%s.%s.%s.", b[1], b[2], b[3]);}'`

# for floating IP and external connectivity
# choose a small pool from the subnet from eth1
POOL_START=${my_ip_pref}100
POOL_END=${my_ip_pref}200
GW=${my_ip_pref}1
CIDR=${my_ip_pref}0/24

source /root/admin-openrc.sh
neutron net-create --shared --router:external --provider:physical_network provider --provider:network_type flat provider1
neutron subnet-create --name provider1-v4 --ip-version 4 \
   --allocation-pool start=$POOL_START,end=$POOL_END \
   --gateway $GW provider1 $CIDR

