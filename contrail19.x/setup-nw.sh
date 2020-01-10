#!/usr/bin/env bash

set -e
set -x

# Creation of network from neutron cli 
apt-get install -y python-virtualenv
export LC_ALL=C
virtualenv /root/os-venv
source /root/os-venv/bin/activate
pip install python-openstackclient
pip install python-ironicclient
apt install -y python-neutronclient
sudo python -m easy_install --upgrade pyOpenSSL

source /root/admin-openrc.sh
neutron net-create public --shared --router:external True
neutron subnet-create --gateway ${gateway_ip} --allocation-pool start=${start_pool},end=${end_pool} public ${external_network}
deactivate

docker exec -it vrouter_vrouter-agent_1 python /opt/contrail/utils/provision_vgw_interface.py --oper create --interface vgw1 --subnets ${ipam_public_net}  --routes 0.0.0.0/0 --vrf default-domain:admin:public:public

echo 1 >> /proc/sys/net/ipv4/conf/vgw1/proxy_arp
echo 1 >> /proc/sys/net/ipv4/conf/vhost0/proxy_arp
echo "net.ipv4.conf.vgw1.proxy_arp = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.vhost0.proxy_arp = 1" >> /etc/sysctl.conf

cat /etc/sysctl.conf
