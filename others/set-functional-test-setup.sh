set -e
set -x

./set-roles.sh
./network-setup.sh
cd /root/files/ && ./router-aap.sh && cd -
./upload-image.sh
sleep 60
./create-se-flavor.sh
./set-securitygroup.sh
./create-nginx-vm.sh
sleep 10
./set-clientvm-fip.sh
