#!/usr/bin/env bash
echo "ubuntu:avi123" | chpasswd
echo "root:avi123" | chpasswd

# Note: proper name server is passed while creating subnet so that the
# instance gets the nameserver. This is crucial for apt-get install to
# work.
#sed -i '1s/^/nameserver 10.10.0.100/' /etc/resolv.conf

echo "10.10.20.20 k8sm" >> /etc/hosts
echo "10.10.20.21 k8sn1" >> /etc/hosts
echo "10.10.20.22 k8sn2" >> /etc/hosts

apt-get -y update && apt-get -y upgrade

# Install docker
apt-get install -y docker.io

# Install kubeadm, kubelet, kubectl
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

if grep -q "cgroup-driver=systemd" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
then
    # replace cgroups
    sed -i "s/cgroup-driver=systemd/cgroup-driver=cgroupfs/g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
else
    sudo sed -i '/\[Service\]/a \
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs"' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi

systemctl daemon-reload
systemctl restart kubelet
