#!/usr/bin/env bash

set -e
set -x

source /root/files/demo-openrc.sh

# associate Floating IP to client
p=`neutron port-list -c 'id' -c 'fixed_ips' --format 'value' | grep 10.0.2.20 | cut -d' ' -f1`
openstack floating ip create --port $p provider1
fip=`openstack floating ip list -c 'Floating IP Address' -c 'Fixed IP Address' --format value | grep 10.0.2.20 | cut -d' ' -f1`
echo -e "==== CLIENT FLOATING IP $fip ===="
