set -x
set -e
interface="ens4"
ip_pref=`cat /root/$interface | grep "inet" | grep -v "inet6" | awk '{split($2, b, "."); printf("%s.%s.", b[1], b[2]);}'`
cidr=${ip_pref}0.0/16
my_mac=`cat /root/$interface | grep "ether" | awk '{print $2;}'`
if [ -z "$my_mac" ]; then
    echo "Can't find mac!"
    exit
fi

source /root/files/admin-openrc.sh

#Get mac addresses of router interface to add to allow address pair
mac_address=`openstack port list | grep ${ip_pref}10. | grep ACTIVE | awk '{print $5;}'`
macs=$(echo $mac_address | tr " " "\n")

aaplist=""
for mac in $macs; do
    aaplist="$aaplist mac_address=$mac,ip_address=$cidr"
done

# Resolve openstack-controller
echo "10.50.62.22     openstack-controller.avi.local" >> /etc/hosts
# Clean up any OS_ variables set
for i in `env | grep OS_ | cut -d'=' -f1`;do unset $i;done

# figure out the port-id from lab credentials
source ./lab_openrc.sh

port_id=`neutron port-list | grep "$my_mac" | awk '{print $2;}'`
neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
