#!/usr/bin/env bash
echo "ubuntu:avi123" | chpasswd
echo "root:avi123" | chpasswd

# Note: proper name server is passed while creating subnet so that the
# instance gets the nameserver. This is crucial for apt-get install to
# work.
#sed -i '1s/^/nameserver 10.10.0.100/' /etc/resolv.conf

apt-get update
#apt-get install --force-yes -y curl

# For trusty manually run dhclient
# TODO: put the following in /etc/rc.local to run on reboot
dhclient -6 eth1
