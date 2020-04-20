# Deploying 19.x All-In-One On OpenStack

`openstack.sh` script brings up All-In-One Contrail 19.x in a VM/BM node.
The underlying orchestrator is OpenStack Kolla Ansible and Contrail Ansible Deployer.
This script uses single interface for management, control and data networks.

#### Steps

1. Create (or check) a flavor with RAM, CPU and Disk size as required by Contrail 19.x. Check the Contrail requirements: https://www.juniper.net/documentation/en_US/contrail19/topics/task/installation/hardware-reqs-vnc.html
2. Make sure you have required Ubuntu/CentOS image.
3. Bring up VM/BM with the flavor, required image, and an interface from desired network. Make sure the network has free IP addresses you can use to create a public network in the AIO OpenStack.
4. Make sure you have the exact kernel version as mentioned in requirements guide. Otherwise upgrade/downgrade the kernel version.
5. Install ansible and docker-ce of required versions, check the Contrail hardware/software requirements guide.
6. Define following environment variables:
```python
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
ipam_public_net
'CIDR of public network to be create on AIO setup'
```
7. Run `openstack.sh` script.
