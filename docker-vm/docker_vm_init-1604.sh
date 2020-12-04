#!/bin/bash

echo "ubuntu:avi123" | chpasswd
echo "root:avi123" | chpasswd

export DEBIAN_FRONTEND=noninteractive
apt-get -y update && apt-get -y upgrade
apt autoremove -y

# enable Password authentication and root login
# set root password to avi123
sed -i s/PasswordAuthentication\ no/PasswordAuthentication\ yes/g /etc/ssh/sshd_config
sed -i s/PermitRootLogin\ without-password/PermitRootLogin\ yes/g /etc/ssh/sshd_config
sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config
service ssh restart

# some bug.. found solution online
echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
update-grub

# add hostname to /etc/hosts
echo -n "127.0.0.1 " >> /etc/hosts
cat /etc/hostname >> /etc/hosts

######## INSTALL DOCKER #########

# Uninstall if any
apt-get -y remove docker docker-engine docker.io containerd runc

# install 
apt-get -y update
apt-get -y install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
apt-key fingerprint 0EBFCD88
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get -y update
apt-get -y install docker-ce docker-ce-cli containerd.io


####### ADD LOCAL REPO ##########
echo -e "{\n    \"insecure-registries\": [\"10.50.66.233:5000\"]\n}\n" >| /etc/docker/daemon.json
service docker restart


####### RUN OS CONTAINER ########

VERSION=OPENSTACK_RELEASE
ENS3_IP=$(ifconfig ens3 | awk '/inet addr/{print $2}' | cut -d':' -f2)
IMAGE="10.50.66.233:5000/avinetworks/$VERSION-heat:latest"
SCRIPT="/root/install_scripts/startup"
if [[ $VERSION < "ocata" ]]; then
    SCRIPT="/root/files/startup"
fi

docker run --name=$VERSION-heat -p 9292:9292 -p 35357:35357 \
        -p 8774:8774 -p 5000:5000 -p 8004:8004 -p 9696:9696 \
        -p 8000:8000 \
        --dns 10.79.16.132 --dns 10.79.16.133 \
        --dns-search oc.vmware.com \
        --dns-search eng.vmware.com \
        --dns-search vmware.com \
        -e OSC_IP=$ENS3_IP -e AVI_IP=AVI_CONTROLLER_IP \
        -e HEAT_REPO='https://github.com/avinetworks/avi-heat' \
        -e HEAT_BRANCH=master -d -t -i "$IMAGE" \
        /bin/bash -c "$SCRIPT"

sleep 20
docker logs $VERSION-heat

docker logout
