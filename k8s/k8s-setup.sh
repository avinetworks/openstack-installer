#!/usr/bin/env bash

set -e
set -x

kubeadm init --pod-network-cidr=192.168.0.0/16 >| /root/kubeadm_init.out
kubejoin=`grep 'kubeadm join --token' /root/kubeadm_init.out`

mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config
chown $(id -u):$(id -g) /root/.kube/config

kubectl apply -f \
https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

sleep 180

kubectl get nodes -o wide

# Run the join commands on nodes
sshpass -p "avi123" ssh -o StrictHostKeyChecking=no root@k8sn1 eval "$kubejoin"
sshpass -p "avi123" ssh -o StrictHostKeyChecking=no root@k8sn2 eval "$kubejoin"
