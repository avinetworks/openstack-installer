#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade

adduser --gecos "" aviuser

# add key
mkdir -p /home/aviuser/.ssh
chmod 700 /home/aviuser/.ssh
cat << EOF > /home/aviuser/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUqFpC+0FPbFWBEj02X7jEDu4JPReAsr32y/H+s1nPNgx+qfGdYjEcZDTbxpAviMdgL90og7r0jWfQGFLN2wAJe9leRG8NZa2WVNq4Xrx8G/sdXk1TpqVE5PCNT+xd+q9xK3hGpCcGGq46qspTtcZUkhb0MCXbTyPHNiLh3VlKpQv1zC554z9jYKetj8tR6bGuhdBGd9ths3H7Vzi9ZA5w3hzZU83kHJLTW/vD5deq72lehHCmOjFEBILoQGjg3VEjjhS/PfSf9JkCYfJeJhGwM1dkuveDN9ahJ43XAKXOlPLoUB3YvjoXhbfj+ob4NS328A52M38zdsIi+gHsFpuB root@avi-dev
EOF
chown -R aviuser:aviuser /home/aviuser/.ssh
chmod 700 /home/aviuser/.ssh/authorized_keys

# add keys in root too
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat << EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUqFpC+0FPbFWBEj02X7jEDu4JPReAsr32y/H+s1nPNgx+qfGdYjEcZDTbxpAviMdgL90og7r0jWfQGFLN2wAJe9leRG8NZa2WVNq4Xrx8G/sdXk1TpqVE5PCNT+xd+q9xK3hGpCcGGq46qspTtcZUkhb0MCXbTyPHNiLh3VlKpQv1zC554z9jYKetj8tR6bGuhdBGd9ths3H7Vzi9ZA5w3hzZU83kHJLTW/vD5deq72lehHCmOjFEBILoQGjg3VEjjhS/PfSf9JkCYfJeJhGwM1dkuveDN9ahJ43XAKXOlPLoUB3YvjoXhbfj+ob4NS328A52M38zdsIi+gHsFpuB root@avi-dev
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHTaoO7+AqUSHAk2DRVVGZVc8TYWvBo0rdbAo7DstD3hMqR4A0uA42KFsE2bRSMCz8kEjnG0cvH5FxbEVQGCt0NHzoM0jHk8g5AudRrloRJ/n+bYeWACtsmINi5m9r9CigrUWpQmQR4rTvwhCJPo9azOF0S63v6XNs4Vo+2LK1fr8KxC/dy1fy0cdpXvEva3Wp7AoyBxKagriwHy3Pp6OMroxh57r42H+RkhcYBhEb8uy++GPylXuGO77EWXhlcL1KfXJ0skYnwL9B2OCPnP8Opj0TDWxS6SwtY/WJIR/5eKTFeB5yeFRAwX2Wo9sr8Np86SKA0DUslJENGpa3ivHl root@avi-dev
EOF
chown -R root:root /root/.ssh
chmod 700 /root/.ssh/authorized_keys


# enable Password authentication and root login
# set root password to avi123
sed -i s/PasswordAuthentication\ no/PasswordAuthentication\ yes/g /etc/ssh/sshd_config
sed -i s/PermitRootLogin\ without-password/PermitRootLogin\ yes/g /etc/ssh/sshd_config
sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config
service ssh restart
echo -e 'avi123\navi123' | passwd root

# some bug.. found solution online
echo "GRUB_DISABLE_OS_PROBER=true" >> /etc/default/grub
update-grub

# add sudo
cat << EOF > /etc/sudoers.d/aviuser
aviuser   ALL=(ALL:ALL) NOPASSWD:ALL
EOF


# add eth1 auto up
cat << EOF >> /etc/network/interfaces.d/ens4.cfg
auto ens4
iface ens4 inet dhcp
EOF

ifconfig ens4 up
dhclient ens4

# add hostname to /etc/hosts
echo -n "127.0.0.1 " >> /etc/hosts
cat /etc/hostname >> /etc/hosts

