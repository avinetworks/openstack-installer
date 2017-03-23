set -e
set -x
rm -rf tcertd
mkdir -p tcertd
cd tcertd
openssl genrsa -out ca.key 1024 
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -batch
openssl x509  -in  ca.crt -out ca.pem 
openssl genrsa -out ca-int_encrypted.key 1024 
openssl rsa -in ca-int_encrypted.key -out ca-int.key 
openssl req -new -key ca-int.key -out ca-int.csr -subj "/CN=ca-int.acme.com" 
openssl x509 -req -days 3650 -in ca-int.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out ca-int.crt 
openssl genrsa -out server_encrypted.key 1024 
openssl rsa -in server_encrypted.key -out server.key 
openssl req -new -key server.key -out server.csr -subj "/CN=server.acme.com" 
openssl x509 -req -days 3650 -in server.csr -CA ca-int.crt -CAkey ca-int.key -set_serial 01 -out server.crt

source /root/demo-openrc.sh

barbican secret store --payload-content-type='text/plain' --name='certificate' --payload="$(cat server.crt)"
barbican secret store --payload-content-type='text/plain' --name='private_key' --payload="$(cat server.key)"
barbican secret container create --name='tls_container' --type='certificate' --secret="certificate=$(barbican secret list | awk '/ certificate / {print $2}')" --secret="private_key=$(barbican secret list | awk '/ private_key / {print $2}')"

cd -
