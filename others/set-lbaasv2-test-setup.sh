set -e
set -x

cd /root/files/ && ./router-aap.sh && cd -
./network-setup.sh
./set-roles.sh
./upload-nginx-image.sh
sleep 60
./create-se-flavor.sh
./set-securitygroup.sh
./create-nginx-vm.sh
./cert1.sh
./cert2.sh
sleep 10
./set-clientvm-fip.sh
