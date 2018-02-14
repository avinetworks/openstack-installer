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
# mgmt network
neutron net-create p1 --shared
neutron subnet-create p1 10.0.1.0/24 --name p1 --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show p1 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

# vip ipv4 network
neutron net-create p2 --shared
neutron subnet-create p2 10.0.2.0/24 --name p2 --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show p2 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

# data ipv4 network
neutron net-create p3 --shared
neutron subnet-create p3 10.0.3.0/24 --name p2 --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show p3 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

# vip ipv6 network
neutron net-create vip6 --shared
neutron subnet-create vip6 \
    --name vip6snw \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    a100::/64
#connect router to it
subnetid=`neutron subnet-show vip6snw -c 'id' --format 'value'`
neutron router-interface-add $routerid subnet=$subnetid

# data ipv6 network
neutron net-create data6 --shared
neutron subnet-create data6 \
    --name data6snw \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    b100::/64
#connect router to it
subnetid=`neutron subnet-show data6snw -c 'id' --format 'value'`
neutron router-interface-add $routerid subnet=$subnetid
