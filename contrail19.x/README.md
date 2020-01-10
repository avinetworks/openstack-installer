# Deploying Contrail 19.x All-In-One On OpenStack

`openstack.sh` script brings up All-In-One Contrail 19.x in a VM/BM node.
The underlying orchestrator is OpenStack Kolla Ansible and Contrail Ansible Deployer.
This script uses single interface for management, control and data networks.

#### Steps

1. Create (or check) a flavor with RAM, CPU and Disk size as required by Contrail 19.x/5.x. Check the Contrail requirements: https://www.juniper.net/documentation/en_US/contrail19/topics/task/installation/hardware-reqs-vnc.html
2. Make sure you have required Ubuntu/CentOS image.
3. Bring up VM/BM with the flavor, required image, and an interface from desired network. Make sure the network has free IP addresses you can use to create a public network in the AIO OpenStack.
4. Make sure you have the exact kernel version as mentioned in requirements guide. Otherwise upgrade/downgrade the kernel version.
5. Install ansible and docker-ce of required versions, check the Contrail hardware/software requirements guide.
6. Define following environment variables in env.sh:
```python
IP
'IP address of host e.g. 10.10.10.2'
INTER
'Interface name of host e.g. ens3'
registry_username
'Username for the Contrail Docker registry to pull images'
registry_password
'Password for the Contrail Docker registry to pull images'
keystone_password
'keystone password for openstack'
ssh_password
'Password of host for SSH where we deploy contrail'
gateway_ip
'Gateway IP if the underlying network for creating Public network in AIO setup'
start_pool
'Starting IP of the pool for Public Network'
end_pool
'End IP of the pool for for Public Network'
external_network
'CIDR of network of the VM/BM server where we deploy the contrail'
ipam_public_net
'CIDR of public network to be create on AIO setup'
```
7. source env.sh
8. Change `CONTRAIL_CONTAINER_TAG` in `instances.yaml` to required Container tag. e.g `5.0.2-0.360-queens` or `1909.30-rocky`
9. Run `openstack.sh` script.
10. Make sure VGW interface is created. To test, deploy a VM on AIO public net and check it.
