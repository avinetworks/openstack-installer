set -e
set -x

wget http://cloud-images.ubuntu.com/trusty/20180212/trusty-server-cloudimg-amd64-disk1.img

# upload cirros image to glance in shared
source /root/files/admin-openrc.sh

#glance image-create --name nginx-ssl --disk-format qcow2 --container-format bare --file nginx-ssl.qcow2 --visibility public --progress
glance image-create --name trusty --disk-format qcow2 --container-format bare --file trusty-server-cloudimg-amd64-disk1.img --visibility public --progress
