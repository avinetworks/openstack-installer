set -e
set -x

./set-roles.sh
./upload-nginx-image.sh
sleep 3
./create-se-flavor.sh
./set-securitygroup.sh
./network-setup.sh
./create-nginx-vm.sh
./cert1.sh
./cert2.sh
sleep 3
cd /root/files/ && ./router-aap.sh && cd -
