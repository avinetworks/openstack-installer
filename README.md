# openstack-installer

## Steps for creating a Mitaka Ubuntu instance

### Setup a Ubuntu 14.04 VM with two interfaces properly configured

Use the heat template in vm-heat-template directory to create your Ubuntu 14.04 VM. This template creates two interfaces: eth0 and eth1. Assumption is that the first interface (eth0) is used for providing for all OpenStack service APIs and is also used for communication between compute VMs. The second interface is used for external connectivity and floating IPs for compute VMs. The template also sets those  both interfaces for DHCP to obtain IP addresses. Also, it enables PasswordAuthentication for SSHing into the VM with root. And sets the password for root to "avi123"

Configurable parameters for this template:
  - **flavor**: Default is to use m1.xlarge flavor (8 VCPUS, 16G RAM, 160G disk). You can create a larger flavor for a beefier VM for more extensive testing.
  - **vm_name**: *required* A name for the VM to create
  - **az**: Default is "nova". You can specify an AZ and optionally a host e.g., "nova:openstack-compute6"
  - **net1**: Name of the first network to connect the VM to, aka network for eth0 interface.
  - **net2**: Name of the second network to connect the VM to, aka network for eth1 interface.

For example, the following command creates an instance named "mitaka1" using this template:
   > heat stack-create mitaka1 -P "vm_name=mitaka1;az=nova:openstack-compute6;net1=avimgmt;net2=network-340" -f devstack.yaml --poll

Once stack gets created successfully, it also shows the IP address assigned to eth0.

### Setup Mitaka OpenStack services in the VM created

Following are the steps to install and bring up all mitaka services:
  - SCP the mitaka/ directory in this repository to the VM created in the previous step, and name it "files" on the destination.
 
  > scp -r mitaka root@10.10.11.11:files
  - SSH to the VM and run installer.sh script in files directory. The following command ssh'es to the VM, runs the script, and captures the output of the script execution in file install.out.

  > ssh root@10.10.11.11 "script install.out -c files/installer.sh"
  - This installs and brings up several services on this VM: keystone, nova, neutron (ML2 with linuxbridge plugin), glance, horizon, and heat.
  - You should be able to access the horizon UI at http://\<VM-IP-Address\>/horizon
  
#### Creating external network for floating IP and Internet access to compute VMs

Use the post-install.sh script in files directory for setting up an external network. You need to choose the proper CIDR and allocation pool that will work on eth1 interface of the created VM.

#### Setting up Allowed-Address-Pairs

If the underlying system is OpenStack, then you need to either (i) add some entries to allowed-address-pairs in the neutron port corresponding to eth1, or (ii) disable port-security on the neutron port corresponding to eth1. This is needed because any virtual router created in our OpenStack environment will try to communicate with outside world using a new MAC address. And the underlying OpenStack will drop those packets as it doesn't know about that MAC address.

In the files directory, there is a script router-aap.sh which has necessary commands to enable needed allowed-address-pairs in the underlying OpenStack. Please modify lab_openrc.sh that will allow to communicate with your underlying OpenStack environment. Also modify the "cidr" parameter in script to the right subnet for your setup -- this denotes the IP address range you want to allow your openstack-VM to be able to use.

You need to run this script everytime you create a virtual router in the overlying OpenStack environment.
