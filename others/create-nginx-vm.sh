set -e
set -x

# needed to create with admin login as Ocata policies don't allow users to create ports with specific IP addresses
source /root/files/admin-openrc.sh
#source /root/files/demo-openrc.sh
export OS_PROJECT_NAME=demo

# create client in vip ipv4 and vip6 network
netid=`neutron net-show vip4 -c 'id' --format 'value'`
net6id=`neutron net-show vip6 -c 'id' --format 'value'`
nova boot --flavor m1.se \
    --image trusty \
    --nic net-id=$netid,v4-fixed-ip=10.0.2.20 \
    --nic net-id=$net6id,v6-fixed-ip=a100::20 \
    --user-data ./cloud-init-client.sh \
    --config-drive True \
    client1

sleep 5

# create server in data IPv4 and data IPv6 network
netid=`neutron net-show data4 -c 'id' --format 'value'`
net6id=`neutron net-show data6 -c 'id' --format 'value'`
nova boot --flavor m1.se \
    --image trusty \
    --nic net-id=$netid,v4-fixed-ip=10.0.3.10 \
    --nic net-id=$net6id,v6-fixed-ip=b100::10 \
    --user-data ./cloud-init-server.sh \
    --config-drive True \
    server1

sleep 5
