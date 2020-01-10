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
apt-get install -y ansible
apt-get install -y git
apt-get install sshpass
apt-get install -y docker.io
apt-get install -y python-pip

export LC_ALL=C
pip install ansible==2.4.2
pip install requests

# create instance.yaml file
sed -i 's/interface_ip/'"${IP}"'/g' instances.yaml
sed -i 's/physical_interface_name/'"${INTER}"'/g' instances.yaml
sed -i 's/registry_username/'"${registry_username}"'/g' instances.yaml
sed -i 's/registry_password/'"${registry_password}"'/g' instances.yaml
sed -i 's/keystone_password/'"${keystone_password}"'/g' instances.yaml
sed -i 's/ssh_password/'"${ssh_password}"'/g' instances.yaml
sed -i 's/gateway_ip/'"${gateway_ip}"'/g' instances.yaml
sed -i 's/contrail_container_tag/'"${contrail_container_tag}"'/g' instances.yaml
sed -i 's/openstack_version/'"${openstack_version}"'/g' instances.yaml

# setup for contrail and openstack
mkdir contrail
cd contrail
git clone -b R1909 https://github.com/Juniper/contrail-ansible-deployer.git

cp ../instances.yaml contrail-ansible-deployer/config/instances.yaml
echo $(pwd)
cd contrail-ansible-deployer
echo $(pwd)
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/configure_instances.yml
ansible-playbook -i inventory/ playbooks/install_openstack.yml
export LC_ALL=C
pip --yes uninstall more-itertools
pip install more-itertools==4.0.0
ansible-playbook -i inventory/ -e orchestrator=openstack playbooks/install_contrail.yml

#Kvm user to create compute host
chmod 666 /dev/kvm
groupadd kvm
usermod -a -G kvm root
chown root:kvm /dev/kvm

docker cp kolla_toolbox:/var/lib/kolla/config_files/admin-openrc.sh /root/admin-openrc.sh
