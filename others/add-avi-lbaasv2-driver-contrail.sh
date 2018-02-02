set -e
set -x

avi_cntr_ip="10.10.39.219"
if [ $# -gt 0 ]; then
   avi_cntr_ip=$1
fi
avi_admin_passwd="avi123"
if [ $# -gt 1 ]; then
   avi_admin_passwd=$2
fi
avi_cloud="openstack"
if [ $# -gt 2 ]; then
   avi_cloud=$3
fi
pip install /root/avi-lbaasv2-*.tar.gz 

# delete the existing opencontrail driver
/opt/contrail/utils/service_appliance_set.py --api_server_ip localhost --api_server_port 8082 --oper del --name opencontrail

# add avi as the provider 
/opt/contrail/utils/service_appliance_set.py --api_server_ip localhost --api_server_port 8082 --oper add --admin_user admin --admin_password avi123 --admin_tenant_name admin --name opencontrail --driver "avi_lbaasv2.avi_ocdriver.OpencontrailAviLoadbalancerDriver" --properties '{"address": "$avi_cntr_ip", "user": "admin", "password": "$avi_admin_passwd", "cloud": "$avi_cloud"}'
sleep 60
