set -e
set -x


interface=eth0
myip=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); print a[2];}'`
my_ip_pref=`ifconfig $interface | grep "inet addr" | awk '{split($2, a, ":"); split(a[2], b, "."); printf("%s.%s.%s.", b[1], b[2], b[3]);}'`

# for floating IP and external connectivity
# choose a small pool from the subnet from eth0
POOL_START=${my_ip_pref}129
POOL_END=${my_ip_pref}200
GW=${my_ip_pref}1
CIDR=${my_ip_pref}0/24


CONTRAIL_PKG_LOC=./contrail-install-packages_3.2.7.0-63_ubuntu-14-04mitaka_all.deb

dpkg -i contrail-install-packages_3.2.7.0-63_ubuntu-14-04mitaka_all.deb
cd /opt/contrail/contrail_packages
./setup.sh
cd -
cp oc-testbed.py testbed.py
sed -i "s/MY_IP_PREF/$my_ip_pref/g" testbed.py
sed -i "s/MY_IP/$myip/g" testbed.py
cp testbed.py /opt/contrail/utils/fabfile/testbeds/
cd /opt/contrail/utils/ && fab install_contrail && cd -

# this one reboots the VM; so no use writing any commands after this one
cd /opt/contrail/utils/ && fab setup_all && cd -
