#!/usr/bin/env bash

set -x


export OS_AUTH_URL=http://openstack-controller.avi.local:5000/v3/
export OS_PROJECT_ID=b290c2998abc44c0975e72def6642d39
export OS_PROJECT_NAME="admin"
export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi
# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME
# In addition to the owning entity (tenant), OpenStack stores the entity
# performing the action as the **user**.
export OS_USERNAME="admin"
# With Keystone you pass the keystone password.

# echo "Please enter your OpenStack Password for project $OS_PROJECT_NAME as user $OS_USERNAME: "
# read -sr OS_PASSWORD_INPUT
# export OS_PASSWORD=$OS_PASSWORD_INPUT

export OS_PASSWORD=avi123

# If your configuration has multiple regions, we set that information here.
# OS_REGION_NAME is optional and only valid in certain environments.
export OS_REGION_NAME="RegionOne"
# Don't leave a blank variable, unset it if it was empty
if [ -z "$OS_REGION_NAME" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

if [[ "$#" -ne 2 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

OS_VERSION=$1
AVI_CONTROLLER_IP=$2
VM_NAME="pytest-docker-$OS_VERSION"
USER_DATA_FILE="docker-vm-init-$OS_VERSION.sh"
cp ./docker_vm_init-1604.sh ./$USER_DATA_FILE

# Replace OS_VERSION and Avi Controller IP
sed -i "s/OPENSTACK_RELEASE/$OS_VERSION/g" ./$USER_DATA_FILE
sed -i "s/AVI_CONTROLLER_IP/$AVI_CONTROLLER_IP/g" ./$USER_DATA_FILE
openstack server delete $VM_NAME
netid=`openstack network show avimgmt -c 'id' --format 'value'`
openstack server create --flavor m1.large \
    --image ubuntu-16.04 \
    --user-data ./$USER_DATA_FILE \
    --config-drive True \
    --nic net-id=$netid \
    $VM_NAME
