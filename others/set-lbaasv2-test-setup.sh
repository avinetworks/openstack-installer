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
version=$(nova-manage --version)
if [ ${version} != 19.0.1 ]; then
    ./cert1.sh
    ./cert2.sh
fi
sleep 10
./set-clientvm-fip.sh
