set -e
set -x

./network-setup.sh
cd /root/files/ && ./router-aap.sh && cd -
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
