# Kubernetes On OpenStack

Scripts to install k8s on openstack. This depends on queens/pike
openstack installer. Using queens/pike installer, bring up a heat stack
with all-in-one OpenStack. Run the k8s-install.sh scrip to deploy 3
node k8s cluster.

Limitations
----
1. This installer used kubeadm, and limitations of kubeadm apply here.
2. Only 3 node cluster (1 master, 2 worker) is deployed.
3. Master is not configured to schedule pods.
4. Only master node is allocated a FIP address for reachability. The
   worker nodes need to be accessed from master.
