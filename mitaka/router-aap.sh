set -x
set -e
interface="eth1"
cidr="10.90.0.0/16"

my_mac=`ifconfig $interface | grep "HWaddr" | awk '{print $5;}'`
if [ -z "$my_mac" ]; then
    echo "Can't find mac!"
    exit
fi

# figure out the port-id from lab credentials
source ./lab_openrc.sh
port_id=`neutron port-list | grep "$my_mac" | awk '{print $2;}'`


qrouters=`ip netns list | grep qrouter`
aaplist=""
for qr in $qrouters; do
    mac=`sudo ip netns exec $qr ifconfig | grep qg | awk '{print $5;}'`
    aaplist="$aaplist mac_address=$mac,ip_address=$cidr"
done

neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
