set -e
set -x

# create a router in admin tenant
source /root/files/admin-openrc.sh

# set it to connect to the external network
routerid=`openstack router show adminrouter | grep " id " | awk '{print $4;}'`
extnetid=`openstack network show provider1 | grep " id " | awk '{print $4;}'`

# k8s ipv4 network
neutron net-create k8s --shared
neutron subnet-create k8s 10.10.20.0/24 --name k8snw --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show k8snw | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid
