set -x
set -e
interface="ens4"
ip_pref=`cat /root/$interface | grep "inet" | grep -v "inet6" | awk '{split($2, b, "."); printf("%s.%s.", b[1], b[2]);}'`
cidr=${ip_pref}0.0/16


mac_address=`openstack port list | grep ${ip_pref}0. | grep ACTIVE | awk '{print $5;}'`
macs=$(echo $mac_address | tr " " "\n")

aaplist=""
for mac in $macs; do
    aaplist="$aaplist mac_address=$mac,ip_address=$cidr"
done

neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
