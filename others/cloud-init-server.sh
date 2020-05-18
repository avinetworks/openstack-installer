#!/usr/bin/env bash
echo "ubuntu:avi123" | chpasswd
echo "root:avi123" | chpasswd

sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
service ssh restart

# Note: proper name server is passed while creating subnet so that the
# instance gets the nameserver. This is crucial for apt-get install to
# work.
#sed -i '1s/^/nameserver 10.10.0.100/' /etc/resolv.conf

sed -i "/nameserver/d" /etc/resolv.conf
sed -i "/search/d" /etc/resolv.conf
echo "nameserver 10.142.7.1" >> /etc/resolv.conf

apt-get update
apt-get install --force-yes -y nginx

# Trusty realted changes
# For trusty manually run dhclient
# TODO: put the following in /etc/rc.local to run on reboot
#dhclient -6 eth1
#sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

#touch /usr/local/nginx/conf/cert.pem
#touch /usr/local/nginx/conf/cert.key
touch /root/cert.pem
touch /root/cert.key

echo "-----BEGIN CERTIFICATE-----
MIIEMTCCA5qgAwIBAgIBATANBgkqhkiG9w0BAQUFADCBojELMAkGA1UEBhMCVVMx
CzAJBgNVBAgTAkNBMRUwEwYDVQQHEwxTYW5GcmFuY2lzY28xFTATBgNVBAoTDEZv
cnQtRnVuc3RvbjERMA8GA1UECxMIY2hhbmdlbWUxETAPBgNVBAMTCGNoYW5nZW1l
MREwDwYDVQQpEwhjaGFuZ2VtZTEfMB0GCSqGSIb3DQEJARYQbWFpbEBob3N0LmRv
bWFpbjAeFw0xMzA1MjEyMjM1NThaFw0yMzA1MTkyMjM1NThaMIGiMQswCQYDVQQG
EwJVUzELMAkGA1UECBMCQ0ExFTATBgNVBAcTDFNhbkZyYW5jaXNjbzEVMBMGA1UE
ChMMRm9ydC1GdW5zdG9uMREwDwYDVQQLEwhjaGFuZ2VtZTERMA8GA1UEAxMIY2hh
bmdlbWUxETAPBgNVBCkTCGNoYW5nZW1lMR8wHQYJKoZIhvcNAQkBFhBtYWlsQGhv
c3QuZG9tYWluMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCwgrMDCazup6Eu
4C1Z+FYWKJUEGYk2XQDSL8odowKQB+/qzKddKHYPDhHBWh4qYMmUGKkA5FOLBDEM
60v98H+LmDI1A8ObRuivaAiEnnXa2gtLt5vRJr0ojoVKi0PXSINpjOFTw0OoTqn3
4EFnq9EUrLdbsSuwaMtEl5qVSPH2ywIDAQABo4IBczCCAW8wCQYDVR0TBAIwADAR
BglghkgBhvhCAQEEBAMCBkAwNAYJYIZIAYb4QgENBCcWJUVhc3ktUlNBIEdlbmVy
YXRlZCBTZXJ2ZXIgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFCbLJiHvuBdNwvzL9Mym
K6TmIp5yMIHXBgNVHSMEgc8wgcyAFMSwhp0ufFbses0Q6sbTa3qM+yQzoYGopIGl
MIGiMQswCQYDVQQGEwJVUzELMAkGA1UECBMCQ0ExFTATBgNVBAcTDFNhbkZyYW5j
aXNjbzEVMBMGA1UEChMMRm9ydC1GdW5zdG9uMREwDwYDVQQLEwhjaGFuZ2VtZTER
MA8GA1UEAxMIY2hhbmdlbWUxETAPBgNVBCkTCGNoYW5nZW1lMR8wHQYJKoZIhvcN
AQkBFhBtYWlsQGhvc3QuZG9tYWluggkA2naYrcXgIvowEwYDVR0lBAwwCgYIKwYB
BQUHAwEwCwYDVR0PBAQDAgWgMA0GCSqGSIb3DQEBBQUAA4GBAIZOS0SLxJFL9mnO
LL25L4oOWKj7zDUsBT6h9fBm2uby6eI4KfiCU09JS9W4SY3FDA3es0C/znKyVroE
CS3Luo4IcsBfO35aoWJdC64lo2UMFa2m6pPy8l32JYR6CwDtcFRjGXr26YiFOpuP
1NHOf1CU33VAVtRGHo+AboiPK7uu
-----END CERTIFICATE-----" >| /root/cert.pem

echo "-----BEGIN PRIVATE KEY-----
MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBALCCswMJrO6noS7g
LVn4VhYolQQZiTZdANIvyh2jApAH7+rMp10odg8OEcFaHipgyZQYqQDkU4sEMQzr
S/3wf4uYMjUDw5tG6K9oCISeddraC0u3m9EmvSiOhUqLQ9dIg2mM4VPDQ6hOqffg
QWer0RSst1uxK7Boy0SXmpVI8fbLAgMBAAECgYBz86f9GuILdPshfArOy6Bhtg8O
Pmgw2i+r49D2XxtT2qL0r7RSMj477ZYkWjruw94n93suJs/qxroiLoAhNVfTGKxX
AL2l+la4GaugH5i4a7uJPqnw/hKpZq8yfkBhbPkfio9B5IDfpthXdcRyID18F/NG
slaAl6Xn8RqqNQtBYQJBANn5wb4R9UGjAWOBOJB3YlnZVf2ZWfIEIg8Xra7HnEfi
fq6pcuS02q2Q+VlzPv5kVg88y29srShT/9oVnCD7FfcCQQDPTTd4R/qBc1Uzk8YN
tB47t8UAXv35BiPdTgTdg8W1qpI490Zu/SRN35AmmEMlcnmO5vXtzRN7/EEDDUQ5
UaDNAkB5zs8Mtx5V6pBpGZoRaRWF3iTmjZ6s1tBtnK7LH/LeXNysIDb7RXF6Uqx0
5ykJoepRo4iPoKx2/9HW/gJ8j7NrAkEAtP5yI+6UZVnRVgr7rRNKIlG9CynlDPuz
bJGl5dIbWRXoPRyIvnb+r482SLxAQ/3C7GXy6wFWtbX0/TkkC/edMQJAY1WWr5Ol
Dvuq9lG4qd/YcafEAX5CqNIoRP76mAKFUWiSWelHpBepn+jBDMrxRg1ZEDCFZI+U
lUyAwf/d3s+W6g==
-----END PRIVATE KEY-----" >| /root/cert.key

chmod 600 /root/cert.pem
chmod 600 /root/cert.key

touch /etc/nginx/sites-enabled/default
echo "server {
	listen [::]:80;
  	listen 0.0.0.0:80;

  	listen [::]:443 ssl;
  	listen 0.0.0.0:443 ssl;

  	listen [::]:8080;
  	listen 0.0.0.0:8080;

	listen [::]:8443 ssl;
	listen 0.0.0.0:8443 ssl;

	#ssl_certificate     /usr/local/nginx/conf/cert.pem;
	#ssl_certificate_key /usr/local/nginx/conf/cert.key;

	ssl_certificate     /root/cert.pem;
	ssl_certificate_key /root/cert.key;

	root /usr/share/nginx/html;

	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
		# try_files $uri $uri/ =404;

                index index.html index.htm;
	}
}" >| /etc/nginx/sites-enabled/default

service nginx restart

