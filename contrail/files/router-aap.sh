set -x
set -e
interface="eth0"
cidr="10.90.0.0/16"

my_mac=`ifconfig $interface | grep "HWaddr" | awk '{print $5;}'`
if [ -z "$my_mac" ]; then
    echo "Can't find mac!"
    exit
fi

# Resolve openstack-controller
sed -i "s/nameserver 10.10.0.100\n//g" /etc/resolv.conf
echo "nameserver 10.10.0.100" >> /etc/resolv.conf
sed -i "s/search avi.local\n//g" /etc/resolv.conf
echo "search avi.local" >> /etc/resolv.conf

# figure out the port-id from lab credentials
source ./lab_openrc.sh

port_id=`neutron port-list | grep "$my_mac" | awk '{print $2;}'`
aaplist="mac_address=$my_mac,ip_address=$cidr"
neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
