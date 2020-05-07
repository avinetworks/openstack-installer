#!/usr/bin/env bash

set -e
set -x

version=$(uname -r)
if [ ${version} == 4.15.0-45-generic ]; then
    echo kernal version supported
else
    echo kernal version not supported
    exit 1
fi

apparmor_parser -R /etc/apparmor.d/usr.sbin.libvirtd
apt-get install -y git
apt-get install sshpass
apt-get install -y docker.io
apt-get install -y python-pip

export LC_ALL=C
pip install --upgrade pip
pip install ansible==2.7.10
pip install requests
pip install zipp==0.4.0
pip install configparser==3.5.2

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
git clone -b R1909 https://github.com/Juniper/contrail-ansible-deployer.git

cp ../instances.yaml contrail-ansible-deployer/config/instances.yaml
cp ../contrail19.py contrail-ansible-deployer
echo $(pwd)
cd contrail-ansible-deployer
echo $(pwd)
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/configure_instances.yml
ansible-playbook -i inventory/ playbooks/install_openstack.yml
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/install_contrail.yml

#Kvm user to create compute host
chmod 666 /dev/kvm
groupadd kvm
usermod -a -G kvm root
chown root:kvm /dev/kvm

#wait till contrail UI comes up
echo "Wating for few minutes for contrail UI to come up"
sleep 3m

#Creation of routing using no SDN using contrail configuration.
python contrail19.py --network ${ipam_public_net} --gateway ${gateway_ip} --contrail ${IP}


echo 1 >> /proc/sys/net/ipv4/conf/vhost0/proxy_arp
echo "net.ipv4.conf.vhost0.proxy_arp = 1" >> /etc/sysctl.conf

cat /etc/sysctl.conf

