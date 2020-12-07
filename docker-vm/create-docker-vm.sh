#!/usr/bin/env bash

set -x

export OS_USERNAME="admin"
export OS_PASSWORD=avi123
export OS_AUTH_URL=http://openstack-controller.avi.local:5000/v3/
export OS_PROJECT_ID=b290c2998abc44c0975e72def6642d39
export OS_PROJECT_NAME="admin"
export OS_REGION_NAME="RegionOne"
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3

export OS_USER_DOMAIN_NAME="Default"
if [ -z "$OS_USER_DOMAIN_NAME" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID="default"
if [ -z "$OS_PROJECT_DOMAIN_ID" ]; then unset OS_PROJECT_DOMAIN_ID; fi

# unset v2.0 items in case set
unset OS_TENANT_ID
unset OS_TENANT_NAME

if [[ "$#" -ne 5 ]]; then
    echo "Illegal number of parameters"
    exit 1
fi

##### Upload latest image ####
wget https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img --no-check-certificate
openstack image delete xenial-current
openstack image create --file xenial-server-cloudimg-amd64-disk1.img --container-format bare --disk-format qcow2 xenial-current
rm -f xenial-server-cloudimg-amd64-disk1.img

PREFIX=$1
OS_VERSION=$2
AVI_CONTROLLER_IP=$3

VM_NAME="$PREFIX-docker-$OS_VERSION"
USER_DATA_FILE="docker-vm-init-$OS_VERSION.sh"
cp ./docker_vm_init-1604.sh ./$USER_DATA_FILE

# Replace OS_VERSION and Avi Controller IP
sed -i "s/OPENSTACK_RELEASE/$OS_VERSION/g" ./$USER_DATA_FILE
sed -i "s/AVI_CONTROLLER_IP/$AVI_CONTROLLER_IP/g" ./$USER_DATA_FILE
openstack server delete $VM_NAME
sleep 10
netid=`openstack network show avimgmt -c 'id' --format 'value'`
openstack server create --flavor m1.large \
    --image xenial-current \
    --user-data ./$USER_DATA_FILE \
    --config-drive True \
    --nic net-id=$netid \
    $VM_NAME

WAITTIME=60
echo "Waiting for VM to come up $WAITTIME secs..."
sleep $WAITTIME

openstack server show $VM_NAME -c addresses -f value | cut -d'=' -f2 >| /tmp/docker-vm-ip
