#!/usr/bin/env bash

set -e
set -x

# needed to create with admin login as Ocata policies don't allow users to create ports with specific IP addresses
source /root/files/admin-openrc.sh
#source /root/files/demo-openrc.sh
export OS_PROJECT_NAME=demo

# create client in vip ipv4 and vip6 network
netid=`neutron net-show k8s -c 'id' --format 'value'`
openstack server create --flavor m1.k8smaster \
    --image xenial \
    --user-data ./k8s-init.sh \
    --config-drive True \
    --nic net-id=$netid,v4-fixed-ip=10.10.20.20 \
    --key-name k8skey \
    --security-group sg-k8s-master \
    --wait \
    k8sm

# create server in data IPv4 and data IPv6 network
openstack server create --flavor m1.k8snode \
    --image xenial \
    --user-data ./k8s-init.sh \
    --config-drive True \
    --nic net-id=$netid,v4-fixed-ip=10.10.20.21 \
    --key-name k8skey \
    --security-group sg-k8s-node \
    --wait \
    k8sn1

openstack server create --flavor m1.k8node \
    --image xenial \
    --user-data ./k8s-init.sh \
    --config-drive True \
    --nic net-id=$netid,v4-fixed-ip=10.10.20.22 \
    --key-name k8skey \
    --security-group sg-k8s-node \
    --wait \
    k8sn2

openstack server list
