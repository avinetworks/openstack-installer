#!/usr/bin/env bash

set -e
set -x

version=$(uname -r)
if [ ${version} == 4.4.0-131-generic ]; then
    echo kernal version supported
else
    echo kernal version not supported
    exit 1
fi

apparmor_parser -R /etc/apparmor.d/usr.sbin.libvirtd
apt-get install -y ansible
apt-get install -y git
apt-get install sshpass
apt-get install -y docker.io
apt-get install -y python-pip

export LC_ALL=C
pip install ansible==2.4.2
pip install requests

# create instance.yaml file
IP="$(hostname -I | awk '{print $1}')"
sed -i 's/interface_ip/'"${IP}"'/g' instances.yaml
INTER="$(ifconfig -a | sed 's/[ \t].*//;/^\(lo\|\)$/d' | grep ^e)"
sed -i 's/physical_interface_name/'"${INTER}"'/g' instances.yaml

sed -i 's/registry_username/'"${registry_username}"'/g' instances.yaml
sed -i 's/registry_password/'"${registry_password}"'/g' instances.yaml
sed -i 's/keystone_password/'"${keystone_password}"'/g' instances.yaml
sed -i 's/ssh_password/'"${ssh_password}"'/g' instances.yaml
sed -i 's/gateway_ip/'"${gateway_ip}"'/g' instances.yaml

# setup for contrail and openstack
mkdir contrail
cd contrail
git clone -b R5.0 https://github.com/Juniper/contrail-ansible-deployer.git

cp ../instances.yaml contrail-ansible-deployer/config/instances.yaml
echo $(pwd)
cd contrail-ansible-deployer
echo $(pwd)
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/configure_instances.yml
ansible-playbook -i inventory/ playbooks/install_openstack.yml
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/install_contrail.yml

#Allow to create kvm user to create compute host
chmod 666 /dev/kvm
groupadd kvm
usermod -a -G kvm root
chown root:kvm /dev/kvm

#Creation of network from neutron cli 
apt-get install -y python-virtualenv
export LC_ALL=C
virtualenv kvm
source kvm/bin/activate
pip install python-openstackclient
pip install python-ironicclient
apt install -y python-neutronclient
sudo python -m easy_install --upgrade pyOpenSSL

docker cp kolla_toolbox:/var/lib/kolla/config_files/admin-openrc.sh .
source admin-openrc.sh
neutron net-create public --shared --router:external True
neutron subnet-create --gateway ${gateway_ip} --allocation-pool start=${start_pool},end=${end_pool} public ${external_network}
docker exec -it vrouter_vrouter-agent_1 python /opt/contrail/utils/provision_vgw_interface.py --oper create --interface vgw1 --subnets ${ipam_public_net}  --routes 0.0.0.0/0 --vrf default-domain:admin:public:public

deactivate


echo 1 >> /proc/sys/net/ipv4/conf/vgw1/proxy_arp
echo 1 >> /proc/sys/net/ipv4/conf/vhost0/proxy_arp
echo "net.ipv4.conf.vgw1.proxy_arp = 1" >> /etc/sysctl.conf
echo "net.ipv4.conf.vhost0.proxy_arp = 1" >> /etc/sysctl.conf

cat /etc/sysctl.conf

