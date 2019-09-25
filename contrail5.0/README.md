# Contrail5.0 On OpenStack

Scripts to install Contrail 5.0.2 on openstack. This is done using Kolla Ansible.

# Pre-requisite

Ubuntu 16.04.6 with kernal version 4.4.0-131-generic

Should support Virtualization

Machine should have only one interface

Make sure you are in root user to reslove from permission issues.

```python
Host Machine Resoures:
Harddisk  = 350GB
RAM       = 64GB
CPU       = 16
```
Need to the following variables to be exported

```python
registry_username
'Username for the registry to pull images'
registry_password
'Password for the registry to pull images'
keystone_password
'keystone password for openstack'
ssh_password
'Password of host for SSH where we deploy contrail'
gateway_ip
'Gateway IP'
start_pool
'Starting IP of the pool for compue host'
end_pool
'End IP of the pool for compue host'
external_network
'Network of the Host where we deploy the contrail'
ipam_public_net
'Network of the compute host'
```

