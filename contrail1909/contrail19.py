import requests
import argparse


def ipam_creation(network, gateway):
    network = network.split('/')
    data_ipam='{"network-ipam":{"name":"gatewayless-network-ipam","fq_name":["default-domain","admin","gatewayless-network-ipam"],"display_name":"gatewayless-network-ipam","parent_type":"project","ipam_subnet_method":"flat-subnet","ipam_subnets":{"subnets":[{"subnet":{"ip_prefix":"'+network[0]+'","ip_prefix_len":'+network[1]+'},"addr_from_start":true,"enable_dhcp":true,"default_gateway":"'+gateway+'"}]}}}'
    url = 'http://'+contrail_ip+':8082/network-ipams'
    response = requests.post(url,data = data_ipam , headers = {
        "Content-Type":"application/json; charset=UTF-8"
        })

    if response.status_code != 200:
        raise Exception("Request got failed with %s" %response._content)
    else:
        print "IPAM created succesfully"

def network_creation():
    data_net = '{ "virtual-network": { "parent_type": "project", "fq_name": ["default-domain", "admin", "gatewayless-vn"], "address_allocation_mode": "flat-subnet-only",      "virtual_network_properties" : { "forwarding_mode":"l3"}, "virtual_network_refs":[{ "to":["default-domain","default-project","ip-fabric"]}], "network_ipam_refs": [{ "attr": { "ipam_subnets": []}, "to": ["default-domain", "admin", "gatewayless-network-ipam"]}]}}'
    url = 'http://'+contrail_ip+':8082/virtual-networks'
    response = requests.post(url, data =data_net, headers = {
        "Content-Type":"application/json; charset=UTF-8"
        })
    if response.status_code != 200:
        raise Exception("Request got failed with %s" %response._content)
    else:
        print "Gatewayless virtual network created succesfully"


def policy_creation():
    data_policy = '{ "network-policy":{ "fq_name":["default-domain","admin","gatewaylessVN-to-ipfabric"],"display_name":"gatewaylessVN-to-ipfabric","parent_type":"project",    "network_policy_entries":{ "policy_rule":[{ "action_list":{ "simple_action":"pass","apply_service":null,"gateway_name":null,"log":false,"mirror_to":null,"qos_action":null},"application":[],       "rule_sequence":{ "major":-1,"minor":-1},"direction":"<>","protocol":"any","dst_addresses":[{ "security_group":null,"virtual_network":"default-domain:default-project:ip-fabric","subnet":null,"network_policy":null}],               "src_addresses":[{ "security_group":null,"virtual_network":"default-domain:admin:gatewayless-nw","subnet":null,"network_policy":null}],"src_ports":[{ "start_port":-1,"end_port":-1}],"dst_ports":[{ "start_port":-1,"end_port":-1}]}]}}}'
    url = 'http://'+contrail_ip+':8082/network-policys'
    response = requests.post(url,data = data_policy,  headers = {
        "Content-Type":"application/json; charset=UTF-8"
    })
    if response.status_code != 200:
        raise Exception("Request got failed with %s" %response._content)
    else:
        print "Policy created succesfully"


def network_updation_with_policy():
    url = 'http://'+contrail_ip+':8082/virtual-networks'
    virtual_networks = requests.get(url)
    virtual_network = virtual_networks.json()["virtual-networks"]
    for network in virtual_network:
        if "gatewayless-vn" in network["fq_name"]:
            uuid=network["uuid"]
    data='{ "virtual-network": { "fq_name": ["default-domain", "admin", "gatewayless-vn"],"network_policy_refs":[{ "to":["default-domain","admin","gatewaylessVN-to-ipfabric"],"attr":{ "timer":null,"sequence":{ "major":0,"minor":0}}}]}}'
    url = 'http://'+contrail_ip+':8082/virtual-network/'+uuid
    response = requests.put(url,data = data, headers = {
        "Content-Type":"application/json; charset=UTF-8"
        })
    if response.status_code != 200:
        raise Exception("Request got failed with %s" %response._content)
    else:
        print "Gatewayless Vn is updated with policy"

def fabric_network_creation():
    url = 'http://'+contrail_ip+':8082/virtual-networks'
    virtual_networks = requests.get(url)
    virtual_network = virtual_networks.json()["virtual-networks"]
    for network in virtual_network:
        if "ip-fabric" in network["fq_name"]:
            fabric_uuid=network["uuid"]
    fabric_data='{ "virtual-network": { "fq_name": ["default-domain","default-project","ip-fabric"],"network_policy_refs":[{ "to":["default-domain","admin","gatewaylessVN-to-ipfabric"],"attr":{ "timer":null,"sequence":{ "major":0,"minor":0}}}],"address_allocation_mode": "flat-subnet-only","virtual_network_properties" : { "forwarding_mode":"l3"},"network_ipam_refs": [{ "attr": { "ipam_subnets": []}, "to": ["default-domain", "admin", "gatewayless-network-ipam"]}]}}'
    url = 'http://'+contrail_ip+':8082/virtual-network/'+fabric_uuid
    response = requests.put(url,data = fabric_data, headers = {
        "Content-Type":"application/json; charset=UTF-8"
        })
    if response.status_code != 200:
        raise Exception("Request got failed with %s" %response._content)
    else:
        print "IP-Fabric network is updated with policy and IPAM"


def parse_arguments():
    parser = argparse.ArgumentParser(
            description = 'Network details')
    parser.add_argument(
            '--network',
            required = True,
            help = 'Network of IPAM with prefix eg: 10.102.15.128/25')
    parser.add_argument(
             '--gateway',
             help = 'Gateway IP of the network')
    parser.add_argument(
            '--contrail',
             help = 'ip of contrail')
    return parser.parse_args()

def main():
    global contrail_ip
    args = parse_arguments()
    contrail_ip = args.contrail
    ipam_creation(args.network,args.gateway)
    network_creation()
    policy_creation()
    network_updation_with_policy()
    fabric_network_creation()

if __name__ == '__main__':
    main()


