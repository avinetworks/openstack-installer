#!/usr/bin/env bash

export LC_ALL=C

source ~/admin-openrc.sh

# Download image
wget http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
# Upload image to glance
glance image-create --name xenial \
	--disk-format qcow2 \
	--container-format bare \
	--file ./xenial-server-cloudimg-amd64-disk1.img \
	--visibility public

# Create flavors
openstack flavor create m1.k8smaster --id auto --public --ram 2048 --disk 16 --vcpus 4
openstack flavor create m1.k8snode --id auto --public --ram 1024 --disk 10 --vcpus 2

# Create network
./k8s-nw.sh

source ~/demo-openrc.sh
# Create keypair
mkdir ~/k8skeys
ssh-keygen -t rsa -N "" -f ~/k8skeys/id_rsa
openstack keypair create --public-key ~/k8skeys/id_rsa.pub k8skey

# Create security groups
openstack security group create sg-k8s-master
openstack security group create sg-k8s-node

openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv4' --protocol any --remote-ip 0.0.0.0/0
openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv6' --protocol any --remote-ip ::/0
openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv4' --protocol any --remote-group sg-k8s-master
openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv6' --protocol any --remote-group sg-k8s-master
openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv4' --protocol any --remote-group sg-k8s-node
openstack security group rule create sg-k8s-master --ingress --ethertype 'IPv6' --protocol any --remote-group sg-k8s-node

openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv4' --protocol any --remote-ip 0.0.0.0/0
openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv6' --protocol any --remote-ip ::/0
openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv4' --protocol any --remote-group sg-k8s-node
openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv6' --protocol any --remote-group sg-k8s-node
openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv4' --protocol any --remote-group sg-k8s-master
openstack security group rule create sg-k8s-node --ingress --ethertype 'IPv6' --protocol any --remote-group sg-k8s-master

# Launch VMs
./k8s-create-vms.sh
./k8s-fip.sh
mfip=`cat /root/k8smaster-fip`

# Install kubeadm init
scp -i ~/k8skeys/id_rsa k8s-setup.sh  ubuntu@$mfip:/tmp
sshpass -p "avi123" ssh -o StrictHostKeyChecking=no root@$mfip /tmp/k8s-setup.sh
