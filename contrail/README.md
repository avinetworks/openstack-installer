# OpenStack-Contrail-in-one installer

Requirements:
A VM with at least 8 cores, 32G memory, 160G disk (what I have tested with)

One network that VM is connected to say with CIDR 10.90.205.0/24.
For floating-ip support, we will use a portion of that subnet. For example,
we configure 10.90.205.129 to 10.90.205.150 to be used for floating-ips
in this overlay OpenStack.

## Create a 14.04 VM with one interface

Use the heat template in vm-heat-template directory to create your Ubuntu 14.04 VM. This template assumes that you have a glance image named "14.04". To create one, download the 14.04 server image from https://cloud-images.ubuntu.com/releases/14.04.4/release/ubuntu-14.04-server-cloudimg-amd64-disk1.img and upload it your glance using the following command:
   > glance image-create --name ubuntu-14.04 --disk-format qcow2 --container-format bare --file ./ubuntu-14.04-server-cloudimg-amd64-disk1.img --progress

This template creates one interface: eth0.
The template also sets the interface for DHCP to obtain IP addresses.
Also, it enables PasswordAuthentication for SSHing into the VM with root. And sets the password for root to "avi123"

Configurable parameters for this template:
  - **flavor**: *required* Create a new flavor (8 VCPUS, 32G RAM, 160G disk) and provide that name here.
  - **vm_name**: *required* A name for the VM to create
  - **az**: Default is "nova". You can specify an AZ and optionally a host e.g., "nova:openstack-compute6"
  - **net1**: Name of the network to connect the VM to, aka network for eth0 interface.

For example, the following command creates an instance named "contrail" using this template:
   > cd vm-heat-template; heat stack-create contrail -P "flavor=py.large;vm_name=contrail;az=nova:openstack-compute6;net1=network-340" -f devstack.yaml --poll

Once stack gets created successfully, it also shows the IP address assigned to eth0.

## Install Contrail on the newly created VM

You need Contrail installer debian package for installing full OpenStack with Contrail on this newly created VM.
The following assumes that you have placed "contrail-install-packages_3.2.7.0-63_ubuntu-14-04mitaka_all.deb" in the
files directory. If the name of the package file is different, then please change the name in the installer.sh file
in the files directory.

Copy the files directory to the above created VM and then execute the installer.sh from the files directory.
$> scp -r files root@vm-ip:
$> ssh root@vm-ip "cd files; ./installer.sh"

For floating IP support, run the public-net.sh script:
$> ssh root@vm-ip "cd files; ./public-net.sh" 

#### Setting up Allowed-Address-Pairs

If the underlying system is OpenStack, then you need to either (i) add some entries to allowed-address-pairs in the neutron port corresponding to eth0, or (ii) disable port-security on the neutron port corresponding to eth0. This is needed to ensure that the Contrail VM can use any of the floating IP addresses configured while communicating on the underlay network.

In the files directory, there is a script router-aap.sh which has necessary commands to enable needed allowed-address-pairs in the underlying OpenStack. Please modify lab_openrc.sh that will allow to communicate with your underlying OpenStack environment. Also modify the "cidr" parameter in script to the right subnet for your setup -- this denotes the IP address range you want to allow your openstack-VM to be able to use.

