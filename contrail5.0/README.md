# Contrail5.0 On OpenStack

Scripts to install Contrail 5.0.2 on openstack. This is done using Kolla Ansible.

#Pre-requisite

Need to export the following variables

```python
registry_username
'Username for the registry to pull images'
registry_password
'Password for the registry to pull images'
keystone_password
'keystone password for openstack'
export ssh_password
'Password of host for SSH where we deploy contrail'
export gateway_ip
'Gateway IP'
export start_pool
'Starting IP of the pool for compue host'
export end_pool
'End IP of the pool for compue host'
export external_network
'Network of the Host where we deploy the contrail'
export ipam_public_net
'Network of the compute host'
```

