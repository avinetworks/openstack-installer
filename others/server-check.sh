#!/usr/bin/env bash

set -x

source /root/demo-openrc.sh

sleep_count=0
while [[ $sleep_count -lt 60 ]];
do
    server_cloud_init_status=`openstack console log show --lines 10 server1 | grep Cloud-init | grep 'finished at'`
    if [[ ! -z "$server_cloud_init_status" ]];
    then
        echo "Cloud-Init finished"
        break
    else
        echo "Cloud-Init still not finished"
        sleep_count=$((sleep_count+1))
        sleep 5
    fi
done

set -e

source /root/admin-openrc.sh

router2=`openstack router show router2 -c id -f value`

# IPv4 check
ip netns exec qrouter-$router2 curl http://10.0.3.10
ip netns exec qrouter-$router2 curl -k https://10.0.3.10
# IPv6 check
ip netns exec qrouter-$router2 curl -g http://[b100::10]
ip netns exec qrouter-$router2 curl -g -k https://[b100::10]
