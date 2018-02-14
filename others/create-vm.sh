set -e
set -x

#source /root/files/admin-openrc.sh
source /root/files/demo-openrc.sh

netid=`neutron net-show p2 -c 'id' --format 'value'`
net6id=`neutron net-show data6 -c 'id' --format 'value'`
nova boot --flavor m1.se \
    --image trusty \
    --nic net-id=$netid,v4-fixed-ip=10.0.2.10 \
    --nic net-id=$net6id,v6-fixed-ip=b100::10 \
    --user-data ./cloud-init-server.sh \
    --config-drive True \
    server1

netid=`neutron net-show p1 -c 'id' --format 'value'`
net6id=`neutron net-show vip6 -c 'id' --format 'value'`
nova boot --flavor m1.se \
    --image trusty \
    --nic net-id=$netid,v4-fixed-ip=10.0.1.20 \
    --nic net-id=$net6id,v6-fixed-ip=a100::20 \
    --user-data ./cloud-init-client.sh \
    --config-drive True \
    client1

# associate Floating IP to client
p=`neutron port-list -c 'id' -c 'fixed_ips' --format 'value' | grep 10.0.1.20 | cut -d' ' -f1`
openstack floating ip create --port $p provider1
fip=`openstack floating ip list -c 'Floating IP Address' -c 'Fixed IP Address' --format value | grep 10.0.1.20 | cut -d' ' -f1`
echo -e "==== CLIENT FLOATING IP $fip ===="
