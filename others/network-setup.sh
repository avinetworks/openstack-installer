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
neutron net-create mgmt --shared
neutron subnet-create mgmt 10.0.1.0/24 --name mgmtsnw --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show mgmtsnw | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

# vip ipv4 network
neutron net-create vip4 --shared
neutron subnet-create vip4 10.0.2.0/24 --name vip4snw --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show vip4snw | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

# data ipv4 network
neutron net-create data4 --shared
neutron subnet-create data4 10.0.3.0/24 --name data4snw --dns-nameserver 10.10.0.100
#connect router to it
subnetid=`openstack subnet show data4snw | grep " id " | awk '{print $4;}'`
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
