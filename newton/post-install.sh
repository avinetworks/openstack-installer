set -e
set -x


# for floating IP and external connectivity
# choose a small pool from the subnet from eth1
POOL_START=
POOL_END=
GW=
CIDR=

source /root/admin-openrc.sh
neutron net-create --shared --router:external --provider:physical_network provider --provider:network_type flat provider1
neutron subnet-create --name provider1-v4 --ip-version 4 \
   --allocation-pool start=$POOL_START,end=$POOL_END \
   --gateway $GW provider1 $CIDR

