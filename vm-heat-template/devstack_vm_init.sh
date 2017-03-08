#!/bin/bash

adduser --gecos "" aviuser

# add key
mkdir -p /home/aviuser/.ssh
chmod 700 /home/aviuser/.ssh
cat << EOF > /home/aviuser/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUqFpC+0FPbFWBEj02X7jEDu4JPReAsr32y/H+s1nPNgx+qfGdYjEcZDTbxpAviMdgL90og7r0jWfQGFLN2wAJe9leRG8NZa2WVNq4Xrx8G/sdXk1TpqVE5PCNT+xd+q9xK3hGpCcGGq46qspTtcZUkhb0MCXbTyPHNiLh3VlKpQv1zC554z9jYKetj8tR6bGuhdBGd9ths3H7Vzi9ZA5w3hzZU83kHJLTW/vD5deq72lehHCmOjFEBILoQGjg3VEjjhS/PfSf9JkCYfJeJhGwM1dkuveDN9ahJ43XAKXOlPLoUB3YvjoXhbfj+ob4NS328A52M38zdsIi+gHsFpuB root@avi-dev
EOF
chown -R aviuser:aviuser /home/aviuser/.ssh
chmod 700 /home/aviuser/.ssh/authorized_keys

# add key in root too
mkdir -p /root/.ssh
chmod 700 /root/.ssh
cat << EOF > /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCUqFpC+0FPbFWBEj02X7jEDu4JPReAsr32y/H+s1nPNgx+qfGdYjEcZDTbxpAviMdgL90og7r0jWfQGFLN2wAJe9leRG8NZa2WVNq4Xrx8G/sdXk1TpqVE5PCNT+xd+q9xK3hGpCcGGq46qspTtcZUkhb0MCXbTyPHNiLh3VlKpQv1zC554z9jYKetj8tR6bGuhdBGd9ths3H7Vzi9ZA5w3hzZU83kHJLTW/vD5deq72lehHCmOjFEBILoQGjg3VEjjhS/PfSf9JkCYfJeJhGwM1dkuveDN9ahJ43XAKXOlPLoUB3YvjoXhbfj+ob4NS328A52M38zdsIi+gHsFpuB root@avi-dev
EOF
chown -R root:root /root/.ssh
chmod 700 /root/.ssh/authorized_keys


# enable Password authentication and root login
# set root password to avi123
sed -i s/PasswordAuthentication\ no/PasswordAuthentication\ yes/g /etc/ssh/sshd_config
sed -i s/PermitRootLogin\ without-password/PermitRootLogin\ yes/g /etc/ssh/sshd_config
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
cat << EOF >> /etc/network/interfaces.d/eth1.cfg
auto eth1
iface eth1 inet dhcp
EOF

ifconfig eth1 up
dhclient eth1

