set -e
set -x
rm -rf tcertd
mkdir -p tcertd
cd tcertd
openssl genrsa -out ca2.key 1024 
openssl req -new -x509 -days 3650 -key ca2.key -out ca2.crt -batch
openssl x509  -in  ca2.crt -out ca2.pem 
openssl genrsa -out ca-int_encrypted2.key 1024 
openssl rsa -in ca-int_encrypted2.key -out ca-int2.key 
openssl req -new -key ca-int2.key -out ca-int2.csr -subj "/CN=ca-int-test2.stacme.com" 
openssl x509 -req -days 3650 -in ca-int2.csr -CA ca2.crt -CAkey ca2.key -set_serial 01 -out ca-int2.crt 
openssl genrsa -out server_encrypted2.key 1024 
openssl rsa -in server_encrypted2.key -out server2.key 
openssl req -new -key server2.key -out server2.csr -subj "/CN=*.stacme.com" 
openssl x509 -req -days 3650 -in server2.csr -CA ca-int2.crt -CAkey ca-int2.key -set_serial 01 -out server2.crt

source /root/demo-openrc.sh

barbican secret store --payload-content-type='text/plain' --name='certificate2' --payload="$(cat server2.crt)"
barbican secret store --payload-content-type='text/plain' --name='private_key2' --payload="$(cat server2.key)"
barbican secret container create --name='tls_container2' --type='certificate' --secret="certificate=$(barbican secret list | awk '/ certificate2 / {print $2}')" --secret="private_key=$(barbican secret list | awk '/ private_key2 / {print $2}')"

cd -
