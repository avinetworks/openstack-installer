set -e
set -x

source /root/files/admin-openrc.sh

openstack role add --user admin --project demo admin

# Set a higher quota
admin=`openstack project list -c ID -c Name -f value | grep -i admin | cut -d' ' -f1`
demo=`openstack project list -c ID -c Name -f value | grep -i demo | cut -d' ' -f1`

openstack quota set --networks 100 --subnets 100 --ports 100 $admin
openstack quota set --networks 100 --subnets 100 --ports 100 $demo
