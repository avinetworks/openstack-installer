set -e
set -x

# upload cirros image to glance in shared
source /root/files/admin-openrc.sh

glance image-create --name nginx-ssl --disk-format qcow2 --container-format bare --file nginx-ssl.qcow2 --visibility public --progress
