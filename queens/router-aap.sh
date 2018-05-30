set -x
set -e
interface="ens4"
cidr="10.90.0.0/16"

for e in `env | grep ^OS_ | cut -d'=' -f1`; do unset $e; done
my_mac=`ifconfig $interface | grep "HWaddr" | awk '{print $5;}'`
if [ -z "$my_mac" ]; then
    echo "Can't find mac!"
    exit
fi

# figure out the port-id from lab credentials
source ./lab_openrc.sh
# add openstack-controller to /etc/hosts
sed -i "s/10.10.16.82 openstack-controller\n//g" /etc/hosts
echo "10.10.16.82 openstack-controller" >> /etc/hosts
port_id=`neutron port-list | grep "$my_mac" | awk '{print $2;}'`


qrouters=`ip netns list | grep qrouter | cut -f 1 -d ' '`
aaplist=""
for qr in $qrouters; do
    mac=`sudo ip netns exec $qr ifconfig | grep qg | awk '{print $5;}'`
    aaplist="$aaplist mac_address=$mac,ip_address=$cidr"
done

neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
