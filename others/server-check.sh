#!/usr/bin/env bash

set -e
set -x

source /root/admin-openrc.sh

router2=`openstack router show router2 -c id -f value`

# IPv4 check
ip netns exec qrouter-$router2 curl http://10.0.3.10
ip netns exec qrouter-$router2 curl -k https://10.0.3.10
# IPv6 check
ip netns exec qrouter-$router2 curl -g http://[b100::10]
ip netns exec qrouter-$router2 curl -g -k https://[b100::10]
