set -x
set -e

# explicitly set locale to avoid any pip install issues
export LC_ALL=C

cp /root/files/demo-openrc.sh /root/
cp /root/files/admin-openrc.sh /root/
source /root/admin-openrc.sh

export DEBIAN_FRONTEND=noninteractive
interface=ens3
my_ip=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); print a[2];}'`

# lbaas
git clone https://github.com/openstack/neutron-lbaas
cd /root/neutron-lbaas
git checkout origin/stable/queens -b queens
python setup.py sdist
pip install dist/*tar.gz
cd -
sed -i "s/service_plugins = router/service_plugins = router,neutron_lbaas.services.loadbalancer.plugin.LoadBalancerPluginv2/g" /etc/neutron/neutron.conf
cat << EOF >> /etc/neutron/neutron.conf
[service_providers]
service_provider = LOADBALANCERV2:Haproxy:neutron_lbaas.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default

[service_auth]
auth_version = 3
admin_password = avi123
admin_user = admin
admin_tenant_name = demo
#auth_uri = http://127.0.0.1:5000/v2.0
auth_url = http://127.0.0.1:5000/v3
admin_user_domain = default
admin_project_domain = default

EOF
neutron-db-manage --subproject neutron-lbaas upgrade head
service neutron-server restart

# lbaas-dashboard
git clone https://git.openstack.org/openstack/neutron-lbaas-dashboard
cd neutron-lbaas-dashboard
git checkout origin/stable/queens -b queens
python setup.py sdist
pip install dist/*tar.gz
cd -
cp neutron-lbaas-dashboard/neutron_lbaas_dashboard/enabled/_1481_project_ng_loadbalancersv2_panel.py /usr/share/openstack-dashboard/openstack_dashboard/local/enabled/
cd /usr/share/openstack-dashboard/
./manage.py collectstatic --noinput
./manage.py compress
cd -
service apache2 restart

# barbican
mysql -u root --password="avi123" -e "CREATE DATABASE barbican;"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'localhost' IDENTIFIED BY 'avi123';"
mysql -u root --password="avi123" -e "GRANT ALL PRIVILEGES ON barbican.* TO 'barbican'@'%' IDENTIFIED BY 'avi123';"

openstack user create --domain default --password avi123 barbican
openstack role add --project service --user barbican admin
openstack role create creator
openstack role add --project service --user barbican creator
openstack role add --project admin --user admin creator
openstack role add --project demo --user demo creator

openstack service create --name barbican   --description "Key Manager" key-manager
openstack endpoint create --region RegionOne   key-manager public http://$my_ip:9311
openstack endpoint create --region RegionOne   key-manager internal http://$my_ip:9311
openstack endpoint create --region RegionOne   key-manager admin http://$my_ip:9311
apt-get install barbican-api barbican-keystone-listener barbican-worker -y
cp /root/files/barbican.conf /etc/barbican/
cp /root/files/barbican-api-paste.ini /etc/barbican/
sed -i "s/localhost:9311/$my_ip:9311/g" /etc/barbican/barbican.conf
sed -i "s/db_auto_create = True/db_auto_create = False/g" /etc/barbican/barbican.conf
su -s /bin/sh -c "barbican-manage db upgrade" barbican
service apache2 restart

