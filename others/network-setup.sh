set -e
set -x

# create a router in admin tenant
source /root/files/admin-openrc.sh

# create router
openstack router create adminrouter
# set it to connect to the external network
routerid=`openstack router show adminrouter | grep " id " | awk '{print $4;}'`
extnetid=`openstack network show provider1 | grep " id " | awk '{print $4;}'`
neutron router-gateway-set $routerid $extnetid

# create couple of networks in admin tenant
neutron net-create p1 --shared
neutron subnet-create p1 10.0.1.0/24 --name p1
#connect router to it
subnetid=`openstack subnet show p1 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

neutron net-create p2 --shared
neutron subnet-create p2 10.0.2.0/24 --name p2
#connect router to it
subnetid=`openstack subnet show p2 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid
