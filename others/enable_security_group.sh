#!/usr/bin/env bash

set -e
set -x

if [[ "$1" == "DISABLE" ]]; then
        echo "DISABLING SECURITY GROUP"
        sed -i 's/security_group_api\ =\ neutron/security_group_api\ =\ nova/g' /etc/nova/nova.conf

        sed -i 's/enable_ipset\ =\ True/enable_ipset\ =\ False/g' /etc/neutron/plugins/ml2/ml2_conf.ini
        sed -i 's/enable_security_group\ =\ True/enable_security_group\ =\ False/g' /etc/neutron/plugins/ml2/ml2_conf.ini
        #sed -i 's/#firewall_driver\ =/firewall_driver\ =\ neutron.agent.firewall.NoopFirewallDriver/g' /etc/neutron/plugins/ml2/ml2_conf.ini

        sed -i 's/enable_security_group\ =\ True/enable_security_group\ =\ False/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
        sed -i 's/firewall_driver\ =\ neutron.agent.linux.iptables_firewall.IptablesFirewallDriver/firewall_driver\ =\ neutron.agent.firewall.NoopFirewallDriver/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
else
        echo "ENABLING SECURITY GROUP"
        sed -i 's/security_group_api\ =\ nova/security_group_api\ =\ neutron/g' /etc/nova/nova.conf

        sed -i 's/enable_ipset\ =\ False/enable_ipset\ =\ True/g' /etc/neutron/plugins/ml2/ml2_conf.ini
        sed -i 's/enable_security_group\ =\ False/enable_security_group\ =\ True/g' /etc/neutron/plugins/ml2/ml2_conf.ini
        #sed -i 's/firewall_driver\ =\ neutron.agent.firewall.NoopFirewallDriver/#firewall_driver\ =/g' /etc/neutron/plugins/ml2/ml2_conf.ini

        sed -i 's/enable_security_group\ =\ False/enable_security_group\ =\ True/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
        sed -i 's/firewall_driver\ =\ neutron.agent.firewall.NoopFirewallDriver/firewall_driver\ =\ neutron.agent.linux.iptables_firewall.IptablesFirewallDriver/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
fi

service neutron-server restart
service neutron-linuxbridge-agent restart
service nova-api restart
service nova-compute restart
echo "Sleeping for 30s for servives to come up..."
sleep 30
