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

# create router for data networks (BE) not connected to VIP networks (FE)
openstack router create router2
# set it to connect to the external network
router2id=`openstack router show router2 | grep " id " | awk '{print $4;}'`
neutron router-gateway-set $router2id $extnetid

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
neutron router-interface-add $router2id subnet=$subnetid

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
neutron router-interface-add $router2id subnet=$subnetid

# ==== SECONDARY NETWORKS ==== #
# vip42 ipv4 network
neutron net-create vip42 --shared
neutron subnet-create vip42 192.168.2.0/24 --name vip42snw --dns-nameserver 10.10.0.100
# connect router to it
# subnetid=`openstack subnet show vip4snw | grep " id " | awk '{print $4;}'`
# neutron router-interface-add $routerid subnet=$subnetid

# data42 ipv4 network
neutron net-create data42 --shared
neutron subnet-create data42 192.168.3.0/24 --name data42snw --dns-nameserver 10.10.0.100
# connect router to it
# subnetid=`openstack subnet show data4snw | grep " id " | awk '{print $4;}'`
# neutron router-interface-add $router2id subnet=$subnetid

# vip ipv6 network
neutron net-create vip62 --shared
neutron subnet-create vip62 \
    --name vip62snw \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    a200::/64
# connect router to it
# subnetid=`neutron subnet-show vip6snw -c 'id' --format 'value'`
# neutron router-interface-add $routerid subnet=$subnetid

# data ipv6 network
neutron net-create data62 --shared
neutron subnet-create data62 \
    --name data62snw \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    b200::/64
# connect router to it
# subnetid=`neutron subnet-show data6snw -c 'id' --format 'value'`
# neutron router-interface-add $router2id subnet=$subnetid


# ==== DUAL STACK NETWORKS ==== #
# Dual-Stack network ds1
neutron net-create ds1 --shared
neutron subnet-create ds1 \
    --name ds1snw4 \
    --ip-version 4 \
    --dns-nameserver 10.10.0.100
    172.16.1.0/24
subnetid=`openstack subnet show ds1snw4 | grep " id " | awk '{print $4;}'`
neutron router-interface-add $routerid subnet=$subnetid

neutron subnet-create ds1 \
    --name ds1snw6 \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    c100::/64
subnetid=`neutron subnet-show ds1snw6 -c 'id' --format 'value'`
neutron router-interface-add $routerid subnet=$subnetid

# Dual-Stack network ds2
neutron net-create ds2 --shared
neutron subnet-create ds2 \
    --name ds2snw4 \
    --ip-version 4 \
    --dns-nameserver 10.10.0.100
    172.16.2.0/24
# subnetid=`openstack subnet show ds2snw4 | grep " id " | awk '{print $4;}'`
# neutron router-interface-add $routerid subnet=$subnetid

neutron subnet-create ds2 \
    --name ds2snw6 \
    --ip-version 6 \
    --ipv6_address_mode=dhcpv6-stateful \
    --ipv6_ra_mode=dhcpv6-stateful \
    c200::/64
# subnetid=`neutron subnet-show ds2snw6 -c 'id' --format 'value'`
# neutron router-interface-add $routerid subnet=$subnetid
